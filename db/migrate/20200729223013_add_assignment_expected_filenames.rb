class AddAssignmentExpectedFilenames < ActiveRecord::Migration[6.0]
  def change
    add_column :assignments, :expected_input_filenames, :string, default: ''
  end
end
