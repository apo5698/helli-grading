class Program < ApplicationRecord
  has_many :child_programs,
           class_name: 'Program',
           foreign_key: :parent_program_id,
           dependent: :nullify,
           inverse_of: :parent_program
  belongs_to :parent_program,
             class_name: 'Program',
             optional: true,
             inverse_of: :child_programs
  belongs_to :assignment

  validates :name, presence: true

  after_initialize -> { self.extension ||= File.extname(name) }
end
