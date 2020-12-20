# frozen_string_literal: true

module CSVGenerator
  @moodle_header ||= Helli::CSV::Adapter::MoodleGradingWorksheet::HEADER
  @zybooks_header ||= Helli::CSV::Adapter::ZybooksActivityReport::HEADER
  @datetime_format ||= Helli::CSV::Adapter::MoodleGradingWorksheet::DATETIME_FORMAT

  class << self
    def moodle(participants = rand(20..30), no_submission: rand(1..5))
      raise ArgumentError, 'participants should be greater than no_submission count' if participants < no_submission

      list = []
      base_identifier = rand(10_000..9_999_999 - participants)
      datetime_now = DateTime.now

      (participants - no_submission).times do |i|
        row = {}

        row[@moodle_header[:identifier]] = "Participant #{base_identifier + i}"
        first_name = self.first_name
        last_name = self.last_name
        row[@moodle_header[:full_name]] = "#{first_name} #{last_name}"
        row[@moodle_header[:email_address]] = ncsu_email(first_name, last_name)
        row[@moodle_header[:status]] = Grade.statuses[:submitted]
        row[@moodle_header[:grade]] = ''
        row[@moodle_header[:maximum_grade]] = '10.00'
        row[@moodle_header[:grade_can_be_changed]] = 'Yes'
        timestamp = moodle_datetime(datetime_now)
        row[@moodle_header[:last_modified_submission]] = timestamp
        row[@moodle_header[:last_modified_grade]] = timestamp
        row[@moodle_header[:feedback_comments]] = ''

        list << row
      end

      no_submission.times do |i|
        row = {}

        row[@moodle_header[:identifier]] = "Participant #{base_identifier + participants + i}"
        first_name = self.first_name
        last_name = self.last_name
        row[@moodle_header[:full_name]] = "#{first_name} #{last_name}"
        row[@moodle_header[:email_address]] = ncsu_email(first_name, last_name)
        row[@moodle_header[:status]] = Grade.statuses[:no_submission]
        row[@moodle_header[:grade]] = ''
        row[@moodle_header[:maximum_grade]] = '10.00'
        row[@moodle_header[:grade_can_be_changed]] = 'Yes'
        row[@moodle_header[:last_modified_submission]] = moodle_datetime(nil)
        row[@moodle_header[:last_modified_grade]] = moodle_datetime(nil)
        row[@moodle_header[:feedback_comments]] = ''

        list << row
      end

      list
    end

    def zybooks(participants = rand(20..30))
      list = []

      participants.times do
        row = {}

        row[@zybooks_header[:email]] = ncsu_email(first_name, last_name)
        row[@zybooks_header[:total]] = Faker::Number.decimal(l_digits: 2, r_digits: 2)

        list << row
      end

      list
    end

    private

    # Word characters only
    def first_name
      Faker::Name.first_name.gsub(/\W/, '')
    end

    # Word characters only
    def last_name
      Faker::Name.last_name.gsub(/\W/, '')
    end

    # <first letter of first name><first 7 letters of last name>@ncsu.edu
    def ncsu_email(first_name, last_name)
      "#{first_name[0]}#{last_name[0..6]}@ncsu.edu".downcase
    end

    # A random date within 7 days ago from today. Return '-' if due_date is +nil+.
    def moodle_datetime(due_date)
      due_date.nil? ? '-' : Faker::Time.between(from: due_date - 7, to: due_date).strftime(@datetime_format)
    end
  end
end
