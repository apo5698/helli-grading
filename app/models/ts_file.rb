class TsFile < ApplicationRecord
  belongs_to :assignment
  has_many_attached :files

  def self.filenames(assignment_id)
    find_by(assignment_id: assignment_id).files.map(&:filename)
  end
end
