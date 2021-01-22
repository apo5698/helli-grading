# frozen_string_literal: true

# Converts an integer term value to string form.
class Term
  SEMESTERS = {
    spring: 'SPRG',
    summer1: 'SUM1',
    fall: 'FALL'
  }.freeze

  UNIX_EPOCH_YEAR = 1970

  attr_accessor :year, :semester

  def initialize(term = nil)
    @time = Time.zone.now

    if term.nil?
      @year = @time.year
      @semester = infer_semester
    else
      @year = UNIX_EPOCH_YEAR + term / SEMESTERS.length
      @semester = SEMESTERS.keys[term % SEMESTERS.length]
    end
  end

  # To term value counted from Unix epoch
  def to_i
    @time.to_i.seconds.in_years.to_i * SEMESTERS.length + SEMESTERS.keys.index(@semester)
  end

  def to_s
    "#{SEMESTERS[@semester]} #{@year}"
  end

  private

  # Infers the current semester.
  # Possible values:
  #   - spring
  #   - summer1
  #   - fall
  #
  # @return [Symbol, nil] semester
  def infer_semester
    config = YAML.load_file('config/ncsu_academic_calendar.yml')
    config[@year].select do |_, v|
      start_date = "#{@year}-#{v['first']}"
      last_date = "#{@year}-#{v['last']}"
      start_date <= @time && @time <= last_date
    end.keys.first&.to_sym
  end

  class << self
    def future_terms(count)
      current = Term.new.to_i
      (current..current + count).map { |i| Term.new(i).to_s }
    end
  end
end
