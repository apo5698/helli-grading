# frozen_string_literal: true

require 'csv'

# Parses csv files.
module Helli::CSV::Parser
  class << self
    # Used for server-side parsing.
    def read(file)
      raise EmptyFileError, file if file.blank?

      str = File.read(file, encoding: 'bom|utf-8')
      raise EmptyFileError, file if str.blank?

      CSV.parse(str, headers: true)
    end

    def header_valid?(expected, actual)
      expected.intersection(actual) == actual
    end

    # Parses the data (from hash) that converted from a csv file with header.
    def parse(data, adapter)
      raise EmptyFileError if data.blank?

      header = adapter.header
      unless header_valid?(data.first.keys.map(&:downcase), header.values.map(&:downcase))
        raise ParseError, 'Unable to parse csv data with invalid headers.'
      end

      adapter.parse(data)
    end

    # Writes the data (from hash) to a csv file.
    def write(data, header = nil)
      raise ArgumentError if data.blank?

      header ||= data.first.keys

      CSV.generate(headers: header, force_quotes: true) do |csv|
        csv << header
        data.each do |row|
          csv << row.values
        end
      end
    end
  end
end
