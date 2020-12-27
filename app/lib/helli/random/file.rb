# frozen_string_literal: true

module Helli
  module Random
    # Generates a random file.
    module File
      class << self
        # Generates a file with random binary string of given bytes (default 16).
        # The result may contain any byte from "\x00" to "\xff"
        #
        # @param [String] filename output filename
        # @param [Integer] bytes number of bytes to write
        def binary(filename, bytes = nil)
          File.write(filename, SecureRandom.random_bytes(bytes))
        end
      end
    end
  end
end
