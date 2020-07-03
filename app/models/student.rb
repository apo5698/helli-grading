class Student < ApplicationRecord
  def <=>(a)
    [last_name, first_name] <=> [a.last_name, a.first_name]
  end
end
