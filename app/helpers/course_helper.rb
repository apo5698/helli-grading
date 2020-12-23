module CourseHelper
  def future_terms
    course = Course.new
    (0..3).map { |i| [course.term!(i).join(' '), course.current_term + i] }
  end
end
