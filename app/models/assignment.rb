class Assignment < ApplicationRecord
  enum assignment_type: [ :exercise, :project, :homework ]
end
