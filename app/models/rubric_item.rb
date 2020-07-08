class RubricItem < ApplicationRecord
  extend DefaultHelper
  include RubricItemsHelper
  has_many :criterions, dependent: :destroy

  enum rubric_item_type: ['Checkstyle', 'Inspection', 'Javadoc', 'Student BBT', 'Student WBT',
                          'TS BBT', 'TS WBT', 'Write/Compile/Execute']

  def self.default_set(type)
    case type
    when 'Write/Compile/Execute'
      default_set_for_wce
    when 'Checkstyle'
      default_set_for_checkstyle
    when 'Javadoc'
      default_set_for_javadoc
    when 'Student BBT'
      default_set_for_student_bbt
    when 'TS WBT'
      default_set_for_ts_wbt
    else
      []
    end
  end

  def self.default_description(type)
    case type
    when 'Student BBT'
      default_description_for_student_bbt
    else
      ''
    end
  end

  def validate(status = :completed, messages = [])
    status, messages = validate_files(status, messages)
    criterions.each do |criterion|
      status, messages = criterion.validate(status, messages)
    end
    [status, messages]
  end
end
