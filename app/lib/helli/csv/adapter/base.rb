# frozen_string_literal: true

module Helli
  module CSV
    module Adapter
      # CSV file adapter.
      class Base
        # Parses the csv data.
        #
        # @param [Hash<String>] data csv data
        # @return [Array<Hash<String>>] parsed data in array of hashes
        def self.parse(data) end
      end
    end
  end
end
