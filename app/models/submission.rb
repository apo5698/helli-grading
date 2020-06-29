class Submission < ApplicationRecord
  belongs_to :student

  def status
    'Not graded'
  end

  def file_submissions
    html = []
    files = ['Hello.java', 'sb', 'Goodbye.java']
    files.each do |file|
      html << "<a href='#'>#{file}</a>"
    end
    html.join('<br />').html_safe
  end
end
