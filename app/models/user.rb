class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, length: {is: 10}, allow_blank: true
  validate :date_of_birth_in_the_past
  validates :gender, inclusion: {in: %w[Male Female]}, allow_blank: true
  validates :password, confirmation: true

  def date_of_birth_in_the_past
    return if date_of_birth.blank?
    return if date_of_birth <= Date.today

    errors.add(:date_of_birth, "can't be in the future")
  end

  def update_avatar(avatar)
    return if avatar.nil?

    filepath = "uploads/avatars/#{avatar.original_filename}"
    file = Rails.root.join('public', filepath)

    # update with the new one
    File.open(file, 'wb') do |f|
      if f.write(avatar.read).zero?
        return 'Error occurred when updating the avatar'
      end
    end

    # delete the old one
    if path_to_avatar
      old_file = Rails.root.join('public', path_to_avatar)
      File.open(old_file, 'r') { |f| File.delete(f) }
    end
    self.path_to_avatar = filepath
    save
    ''
  end
end
