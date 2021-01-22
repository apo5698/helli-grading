module GradingHelper

  def react_grading_page_grade_items(course, assignment, rubric_item, grade_items)
    items = []
    grade_items.each do |grade_item|
      items << react_grading_page_grade_item(course, assignment, rubric_item, grade_item)
    end
    items
  end

  def react_grading_page_grade_item(course, assignment, rubric_item, grade_item)
    { id: grade_item.id,
      status: grade_item.status,
      statusInText: GradeItem.statuses[grade_item.status],
      point: grade_item.point,
      feedback: grade_item.feedback,
      error: grade_item.error,
      stdout: grade_item.stdout,
      stderr: grade_item.stderr,
      participant: { name: grade_item.participant.full_name },
      path: course_assignment_grading_grade_item_path(course, assignment, rubric_item, grade_item) }
  end

  def react_grading_page_rubric_item(course, assignment, rubric_item)
    { id: rubric_item.id,
      name: rubric_item.to_s,
      path: course_assignment_grading_path(course, assignment, rubric_item),
      maxPoint: rubric_item.maximum_points,
      filename: rubric_item.filename,
      type: rubric_item.type.downcase.sub('rubrics::item::', '') }
  end
end
