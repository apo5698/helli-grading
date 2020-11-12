class Rubric
  class Wce < Rubric
    mattr_accessor :title, :usage, :required_fields, :default_set

    self.title = 'Compile & Execute'
    self.usage = 'Compiles and executes a Java file.'
    self.required_fields = [:primary_file]
    self.default_set = Rubric::Compile.default_set + Rubric::Execute.default_set

    # TODO: implement
    # +test_file+ not used
    def grade(primary_file, _, options)
      raise NotImplementedError
    end

    # Converts values of library options from the params to boolean.
    # Returns empty hash if +options[:lib]+ is not defined.
    def self.lib(options)
      return {} unless options[:lib]

      options[:lib].transform_values! { |v| ActiveModel::Type::Boolean.new.cast(v) }
    end
  end
end
