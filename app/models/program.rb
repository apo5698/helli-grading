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

  after_initialize :infer_extension

  # Check uniqueness to its assignment
  before_save -> { raise Assignment::ProgramExists, name unless unique_to_assignment? }

  # Infers the extension from its name.
  #
  # @return [String] extension
  def infer_extension
    return if name.nil?

    self.extension ||= File.extname(name)
  end

  # Checks if the program is unique to its assignment by name.
  #
  # @return [Boolean] uniqueness
  def unique_to_assignment?
    self.class.find_by(assignment_id: assignment.id, name: name).blank?
  end

  def to_s
    name
  end
end
