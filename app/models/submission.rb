class Submission < ApplicationRecord
  include Rails.application.routes.url_helpers
  belongs_to :student
  has_many_attached :files
  has_many :grading_items, dependent: :destroy

  def status
    stat = 0
    case stat
    when 0
      color = '#d9831f'
      type = 'fas fa-question-circle'
      text = 'Not yet graded'
    when 1
      color = '#469408'
      type = 'fas fa-check-circle'
      text = 'Graded'
    else
      color = '#d9230f'
      type = 'fas fa-times-circle'
      text = 'Marked as failed'
    end

    html = "<span data-toggle='tooltip' data-placement='top' data-original-title='#{text}' style='color: #{color}'>"\
           "<i class='#{type}'></i></span>"
    html.html_safe
  end

  def file_submissions
    html = []
    files.each do |file|
      url = rails_blob_path(file, disposition: 'attachment', only_path: true)
      html << "<a href='#{url}'>#{file.filename}</a>"
    end
    html.join('<br />').html_safe
  end
end
