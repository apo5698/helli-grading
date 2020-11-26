module Helli::CSV
  # CSV file adapter.
  class Adapter
    # Parses the data and returns result in a hash.
    def self.parse(data) end
  end

  # Moodle grading worksheets. Typically, the filename matches the pattern:
  #
  #   Grades-CSC 116 (004) FALL 2020-Day 11-293581.csv
  #
  #     Grades-<SUBJECT> <course number> (section) <SEMESTER> <year>-<assignment>-<id>
  #
  #     Grades-[A-Z]+ \d+ \(\d+\s*\) [A-Z]+ \d{4}-.+-\d+.csv
  #
  # All columns are used:
  #   "Identifier", "Full name", "Email address", "Status", "Grade", "Maximum Grade", "Grade can be changed",
  #   "Last modified (submission)", "Last modified (grade)", "Feedback comments"
  class MoodleGradingWorksheetAdapter < Adapter
    # Wednesday, September 23, 2020, 9:00 PM
    DATETIME_FORMAT = '%A, %B %e, %Y, %l:%M %p'.freeze

    HEADER = {
      identifier: 'Identifier',
      full_name: 'Full name',
      email_address: 'Email address',
      status: 'Status',
      grade: 'Grade',
      maximum_grade: 'Maximum Grade',
      grade_can_be_changed: 'Grade can be changed',
      last_modified_submission: 'Last modified (submission)',
      last_modified_grade: 'Last modified (grade)',
      feedback_comments: 'Feedback comments'
    }.freeze

    def self.parse(data)
      data.reduce([]) do |attributes, row|
        lms = row[HEADER[:last_modified_submission]]
        lmg = row[HEADER[:last_modified_grade]]
        attributes << {
          email_address: row[HEADER[:email_address]],
          identifier: row[HEADER[:identifier]].scan(/\d+/).first.to_i,
          full_name: row[HEADER[:full_name]],
          status: row[HEADER[:status]].split('-')[0].strip,
          grade: row[HEADER[:grade]],
          maximum_grade: row[HEADER[:maximum_grade]],
          grade_can_be_changed: row[HEADER[:grade_can_be_changed]] == 'Yes',
          last_modified_submission: lms == '-' ? nil : DateTime.strptime(lms, DATETIME_FORMAT),
          last_modified_grade: lmg == '-' ? nil : DateTime.strptime(lmg, DATETIME_FORMAT),
          feedback_comments: row[HEADER[:feedback_comments]]
        }
      rescue StandardError => e
        raise Helli::ParseError, e.message
      end
    end
  end

  # zyBooks activity reports. Typically, the filename matches the pattern:
  #
  #   NCSUCSC116BalikFall2020_report_004_2020-09-23_2345.csv
  #
  #     <SCHOOL><SUBJECT><course number><Instructor><SEMESTER><Year>_report_<section>_<year>-<month>-<day>_<time>.csv
  #
  #     [A-Z]+\d+[A-Z][a-z]+[A-Z][a-z]+\d+_report_\d+_\d{4}-\d{2}-\d{2}_\d{4}.csv
  #
  # Only two columns are used:
  #   "School email", "Total"
  class ZybooksActivityReportAdapter < Adapter
    HEADER = {
      email: 'School email',
      total: 'Total'
    }.freeze

    def self.parse(data)
      data.reduce([]) do |attributes, row|
        attributes << {
          email: row[HEADER[:email]],
          total: row[HEADER[:total]]
        }
      end
    rescue StandardError => e
      raise Helli::ParseError, e.message
    end
  end
end
