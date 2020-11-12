class Rubric
  # Rubric for calculating zyBooks grades.
  class Zybooks < Rubric
    mattr_accessor :title, :usage, :required_fields, :default_set

    self.title = 'zyBooks'
    self.usage = 'Calculates the zyBooks grades.'
    self.required_fields = []
    self.default_set = []

    def run(_, _, _) end
  end
end
