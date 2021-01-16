# frozen_string_literal: true

class Scale < ApplicationRecord
  serialize :scale, HashIntegerKeysSerializer

  # Sets the grades scale of the assignment. The sum of these values must be 100.
  #
  #   grades_scale = { program = 50, zybooks = 25, other = 25 }
  #     #=> { program: 50, zybooks: 25, other: 25 }
  #
  #   grades_scale = { program = 10, zybooks = 20, other = 30 }
  #     #=> ArgumentError: the sum of values must be 100
  #
  # Although values are all optional, at least one should be provided.
  #
  #   grades_scale = { program = 0 }
  #     #=> ArgumentError: provide at least one value
  #
  # If +other+ is not specified, the sum of +program+ and +zybooks+ will always be 100, no matter
  # one or both values are provided.
  #
  #   grades_scale = { program = 50, zybooks = 50 }
  #     #=> { program: 50, zybooks: 50, other: 0 }
  #
  #   grades_scale = { program = 100 }
  #     #=> { program: 100, zybooks: 0, other: 0 }
  #
  #   grades_scale = { zybooks = 25 }
  #     #=> { program: 75, zybooks: 25, other: 0 }
  def grades_scale=(scale)
    program = scale[:program] || 0
    zybooks = scale[:zybooks] || 0
    other = scale[:other] || 0

    raise ArgumentError, 'provide at least one value' if program.zero? && zybooks.zero? && other.zero?
    raise ArgumentError, 'value must be integer' unless program.is_a?(Integer) && zybooks.is_a?(Integer) && other.is_a?(Integer)
    raise ArgumentError, 'value cannot be negative' if program.negative? || zybooks.negative? || other.negative?

    sum = 100
    if other.zero?
      if program.zero?
        program = sum - zybooks
      elsif zybooks.zero?
        zybooks = sum - program
      end
    end

    raise ArgumentError, "the sum of values must be #{sum}" if program + zybooks + other != sum

    super({ program: program, zybooks: zybooks, other: other })
  end

  # Sets the zyBooks grades scale of the assignment. At least one scale should be provided.
  # The grades must be sorted in the same order as levels.
  #
  #   zybooks_scale = { 90 => 100, 80 => 80 }
  #     #=> { 90 => 100, 80 => 80 }
  #
  #   zybooks_scale = {}
  #     #=> ArgumentError: provide at least one value
  #
  #   zybooks_scale = { 90 => 50, 80 => 60, 70 => 100 }
  #     #=> ArgumentError: grades are not sorted
  def zybooks_scale=(scale)
    raise ArgumentError, 'provide at least one value' if scale.empty?

    scale = scale.map { |k, v| { k.to_i => v.to_i } }.reduce(:merge).sort.reverse.to_h
    raise ArgumentError, 'grades are not sorted' if scale.values.sort.reverse != scale.values

    super(scale)
  end
end
