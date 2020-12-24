class RubricItem
  class Wce < RubricItem
    mattr_accessor :title, :usage, :required_fields, :default_set

    self.title = 'Compile & Execute'
    self.usage = 'Compiles and executes a Java file.'
    self.required_fields = [:primary_file]
    self.default_set = RubricItem::Compile.default_set + RubricItem::Execute.default_set

    # TODO: implement
    # +test_file+ not used
    def grade(primary_file, _, options)
      raise NotImplementedError
    end
  end
end
