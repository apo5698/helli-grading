# frozen_string_literal: true

module Helli
  module Random
    # Generates a random CSV.
    class CSV
      attr_reader :data

      def initialize(type, *args)
        @data = []
        @type = type
        send(type, *args)
      end

      # Writes the random csv string to a file.
      #
      # @param [String] filename name of file to write
      def write(filename)
        ::File.write(filename, Helli::CSV.write(data, @type))
      end

      private

      def moodle(total = rand(20..30), no_submission = rand(1..5))
        raise ArgumentError, 'participants should be greater than no_submission count' if total < no_submission

        moodle_header = Helli::CSV.header(:moodle)
        base_identifier = rand(10_000..9_999_999 - total)
        datetime_now = DateTime.now

        (total - no_submission).times do |i|
          row = {}

          row[moodle_header[:identifier]] = "Participant #{base_identifier + i}"
          first = first_name
          last = last_name
          row[moodle_header[:full_name]] = "#{first} #{last}"
          row[moodle_header[:email_address]] = f1l7_email(first, last)
          row[moodle_header[:status]] = Grade.statuses[:submitted]
          row[moodle_header[:grade]] = ''
          row[moodle_header[:maximum_grade]] = '10.00'
          row[moodle_header[:grade_can_be_changed]] = 'Yes'
          timestamp = moodle_datetime(datetime_now)
          row[moodle_header[:last_modified_submission]] = timestamp
          row[moodle_header[:last_modified_grade]] = timestamp
          row[moodle_header[:feedback_comments]] = ''

          @data << row
        end

        no_submission.times do |i|
          row = {}

          row[moodle_header[:identifier]] = "Participant #{base_identifier + total + i}"
          first = first_name
          last = last_name
          row[moodle_header[:full_name]] = "#{first} #{last}"
          row[moodle_header[:email_address]] = f1l7_email(first, last)
          row[moodle_header[:status]] = Grade.statuses[:no_submission]
          row[moodle_header[:grade]] = ''
          row[moodle_header[:maximum_grade]] = '10.00'
          row[moodle_header[:grade_can_be_changed]] = 'Yes'
          row[moodle_header[:last_modified_submission]] = moodle_datetime(nil)
          row[moodle_header[:last_modified_grade]] = moodle_datetime(nil)
          row[moodle_header[:feedback_comments]] = ''

          @data << row
        end
      end

      def zybooks(participants = rand(20..30))
        zybooks_header = Helli::CSV.header(:zybooks)

        participants.times do
          row = {}

          row[zybooks_header[:email]] = f1l7_email(first_name, last_name)
          row[zybooks_header[:total]] = Faker::Number.decimal(l_digits: 2, r_digits: 2)

          @data << row
        end
      end

      # Word characters only
      def first_name
        Faker::Name.unique.first_name.gsub(/\W/, '')
      end

      # Word characters only
      def last_name
        Faker::Name.unique.last_name.gsub(/\W/, '')
      end

      # <first letter of first name><first 7 letters of last name>@ncsu.edu
      def f1l7_email(first_name, last_name)
        "#{first_name[0]}#{last_name[0..6]}@helli.app".downcase
      end

      # A random date within 7 days ago from today. Return '-' if due_date is +nil+.
      def moodle_datetime(due_date)
        @datetime_format ||= Helli::CSV::Adapter::MoodleGradingWorksheet::DATETIME_FORMAT
        due_date.nil? ? '-' : Faker::Time.between(from: due_date - 7, to: due_date).strftime(@datetime_format)
      end
    end
  end
end
