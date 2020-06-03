class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :phone_number, :limit => 10
      t.date :date_of_birth
      t.string :gender, :limit => 1
      t.string :password
      t.string :path_to_avatar
      t.timestamps
    end
  end
end
