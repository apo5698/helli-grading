module FileGenerator
  class << self
    # Generates a file with random binary string of given bytes (default 16).
    # The result may contain any byte from "\x00" to "\xff"
    def new(filename, bytes = nil)
      raise IOError, "file exists - #{filename}" if File.exist?(filename)

      File.open(filename, 'wb') do |f|
        f.write(SecureRandom.random_bytes(bytes))
      end
    end
  end
end
