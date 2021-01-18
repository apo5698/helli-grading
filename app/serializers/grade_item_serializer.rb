# frozen_string_literal: true

class GradeItemSerializer < ActiveModel::Serializer
  attributes :id, :participant, :filename,
             :status, :stdout, :stderr, :exitstatus, :error, :point, :maximum_points, :feedback

  def participant
    object.participant.full_name
  end

  def filename
    object.rubric_item.filename
  end

  def maximum_points
    object.rubric_item.maximum_points
  end
end
