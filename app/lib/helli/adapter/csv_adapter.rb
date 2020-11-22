module Helli
  module Adapter
    # CSV file adapter.
    class CSVAdapter
      class << self
        mattr_accessor :header

        # Parses the data and returns result in a hash.
        def parse(data) end
      end
    end
  end
end
