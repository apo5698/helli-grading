class Student < ApplicationRecord
  def ==(other)
    email == other.email
  end

  def <=>(other)
    a = name.split(' ')
    b = other.name.split(' ')
    [a[1], a[0]] <=> [b[1], b[0]]
  end
end
