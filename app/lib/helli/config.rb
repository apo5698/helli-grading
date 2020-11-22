module Helli
  class Config
    extension = '.yml'
    config_path = "app/lib/config/**/*#{extension}"

    Dir[config_path].each do |file|
      # define modules
      klass = const_set(File.basename(file, extension).capitalize, Module.new)
      YAML.load_file(file).sort.to_h.symbolize_keys.each do |symbol, value|
        # define methods
        klass.define_singleton_method(symbol) do
          value.is_a?(Hash) ? value.symbolize_keys : value
        end
      end
    end
  end
end
