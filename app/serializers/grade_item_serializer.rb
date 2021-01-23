# frozen_string_literal: true

class GradeItemSerializer < ActiveModel::Serializer
  attributes :id, :participant, :status, :point, :maximum_points, :feedback,
             :stdout, :stderr, :exitstatus, :error

  def status
    GradeItem.statuses[object.status]
  end

  def participant
    object.participant.full_name
  end

  def maximum_points
    object.rubric_item.maximum_points
  end
end
