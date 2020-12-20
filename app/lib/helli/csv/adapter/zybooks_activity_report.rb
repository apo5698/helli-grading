module Helli
  module CSV
    module Adapter
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
      class ZybooksActivityReport < Base
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
  end
end
