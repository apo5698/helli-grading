class RenamePathToAvatarToAvatar < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :path_to_avatar, :avatar
  end
end
