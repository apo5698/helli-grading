# frozen_string_literal: true

# Helli Configurations Utilities.
module Config
  ROOT = 'config/helli'

  class << self
    # Returns the configuration using key.
    #
    # @param [String] key configuration key
    # @return configuration value
    def get(key)
      list = key.split('.')
      filename = "#{ROOT}/#{list.shift}.yml"

      begin
        base = YAML.load_file(filename)
      rescue Errno::ENOENT
        raise FileNotFound, filename
      end

      if list.empty?
        base
      else
        begin
          base.dig(*list)
        rescue TypeError
          raise ValueNotFound, key
        end
      end
    end
  end

  # Raised when the specified configuration file cannot be found.
  class FileNotFound < Helli::ApplicationError
    def initialize(filename)
      super("No such configuration file - #{filename}")
    end
  end

  # Raised when a value for specified key cannot be found.
  class ValueNotFound < Helli::ApplicationError
    def initialize(key)
      super("Value not found for key - #{key}")
    end
  end
end
