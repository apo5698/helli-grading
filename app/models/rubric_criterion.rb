class RubricCriterion < ApplicationRecord
  belongs_to :rubric

  after_create do
    rubric.maximum_grade += point if award?
    rubric.save!
  end

  enum action: {
    award: 'Award',
    award_each: 'Award / ea.',
    deduct: 'Deduct',
    deduct_each: 'Deduct / ea.'
  }

  enum criterion: {
    max_point: 'Maximum points possible',
    filename: 'Filename is %{filename}',
    classname: 'Classname is %{filename}',
    compile: '%{filename} compiles',
    execute: '%{filename} runs',
    checkstyle_warning: '%{filename} has checkstyle warning(s)'
  }

  FEEDBACKS = {
    max_point: '',
    filename: 'File is incorrectly named, expected: %{filename}, actual: %{actual}',
    classname: 'Class is incorrectly named, expected: %{filename}, actual: %{actual}',
    compile: 'Cannot compile %{filename}, %{error} error(s) found',
    execute: 'Cannot run %{filename}, %{error} error(s) found, program exits with %{exitcode}',
    checkstyle_warning: '%{error} checkstyle warning(s)'
  }.freeze

  VARIABLES = {
    filename: 'Filename of the current rubric',
    actual: 'Actual file name',
    output: 'stdout and stderr',
    exitcode: 'Process exit status code',
    error: 'Error count'
  }.freeze
end
