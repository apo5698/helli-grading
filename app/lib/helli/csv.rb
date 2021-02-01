# frozen_string_literal: true

require 'csv'

module Helli
  module CSV
    # Registers subclasses.
    ADAPTERS = {
      moodle: Helli::CSV::Adapter::MoodleGradingWorksheet,
      zybooks: Helli::CSV::Adapter::ZybooksActivityReport
    }.freeze

    private_constant :ADAPTERS

    class << self
      # Returns the csv adapter class.
      #
      # @param [Symbol] type :moodle or :zybooks
      # @return [Helli::CSV::Adapter::Base] adapter class
      def adapter(type)
        raise ArgumentError, "unknown adapter type - #{type}" unless type.in?(ADAPTERS)

        ADAPTERS[type]
      end

      # Returns the header of a certain type of CSV.
      #
      # @param [Symbol] type :moodle or :zybooks
      # @return [Hash] csv header mapping
      def header(type)
        raise ArgumentError, "unknown header type - #{type}" unless type.in?(ADAPTERS)

        ADAPTERS[type]::HEADER
      end

      # Parses the data (from hash) that converted from a csv file with header.
      #
      #   data = [{"School email"=>"a@helli.app", "Total"=>"100"}, {"School email"=>"b@helli.app", "Total"=>"90"}]
      #
      #   adapter = :zybooks
      #
      #   Helli::CSV.parse(data, adapter)
      #   #=> [{:email=>"a@helli.app", :total=>"100.00"}, {:email=>"b@helli.app", :total=>"90.00"}]
      #
      # @param [Array<Hash>] data
      # @param [Symbol] adapter adapter type
      # @return [Array<Hash>] parsed data
      def parse(data, adapter)
        return nil if data.blank?

        unless header_valid?(data.first&.keys&.map(&:downcase), Helli::CSV.header(adapter).values.map(&:downcase))
          raise Helli::ParseError, 'Unable to parse csv data with invalid headers.'
        end

        Helli::CSV.adapter(adapter).parse(data)
      end

      # Converts the csv data to a csv string.
      #
      #   data = [{"School email"=>"a@helli.app", "Total"=>"100.00"},
      #           {"School email"=>"b@helli.app", "Total"=>"90.00"},
      #           {"School email"=>"c@helli.app", "Total"=>"80.00"}]
      #
      #   adapter = :zybooks
      #
      #   Helli::CSV.write(data, adapter)
      #   #=> '"School email","Total"\n"a@helli.app","100.00"\n"b@helli.app","90.00"\n"c@helli.app","80.00"\n'
      #
      # @param [Array<Hash>] data csv data
      # @return [String] csv string
      def write(data, adapter)
        raise ArgumentError if data.blank?

        header = Helli::CSV.header(adapter).values

        ::CSV.generate(headers: header, force_quotes: true) do |csv|
          csv << header
          data.each do |row|
            csv << row.values
          end
        end
      end

      # Checks if a given csv header is valid.
      # In other words, actual header contains all columns from expected.
      #
      #   expected = ['Total', 'School email']
      #   actual = ['Primary email', 'School email', 'Total']
      #
      #   header_valid?(expected, actual) #=> true
      #
      # @param [Array] expected expected values
      # @param [Array] actual actual values
      # @return [Boolean] validity
      def header_valid?(expected, actual)
        expected.intersection(actual) == expected
      end
    end
  end
end
