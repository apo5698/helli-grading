module Helli
  class Resolve
    include String

    enum state: {
      accepted: :accepted,
      rejected: :rejected,
      postponed: :postponed
    }

    alias accept! accepted!
    alias reject! rejected!
    alias postpone! postponed!

    def initialize(object) end

    def resolve(option = {}) end
  end
end
