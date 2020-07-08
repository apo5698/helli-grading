class RubricItem < ApplicationRecord
  extend RubricItemsHelper
  has_many :criterions, dependent: :destroy

  enum rubric_item_type: ['Checkstyle', 'Inspection', 'Javadoc', 'Student BBT', 'Student WBT',
                          'TS BBT', 'TS WBT', 'Write/Compile/Execute']

  def self.default_set(type)
    case type
    when :wce
      default_set_for_wce
    when :checkstyle
      default_set_for_checkstyle
    when :javadoc
      default_set_for_javadoc
    when :student_bbt
      default_set_for_student_bbt
    when :ts_wbt
      default_set_for_ts_wbt
    else
      []
    end
  end

  def self.default_description(type)
    case type
    when :student_bbt
      default_description_for_student_bbt
    else
      ''
    end
  end

end
