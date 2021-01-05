# frozen_string_literal: true

# Custom color mappings. Require Bootstrap v4+.
module Color
  # noinspection SpellCheckingInspection
  class << self
    def rand(seed)
      # IN USE: https://woven-words.com/2012/06/29/story-of-the-color-sky/
      colors = %w[75a3e1 f3d769 f6f4df de5b08 335b44 965b03 c2dfef 7b5ca7 5d5855
                  63aed5 8fb8a3 f0c2c7 c99a3a bd5700 7e5f12 3e7e19 da5990 e38401 4f95c5]
      colors[Random.new(seed).rand(colors.count)]
    end

    def of(kind, type = nil)
      colors = send(kind)
      type ? colors[type.to_sym] : colors
    end

    private

    def flash
      { alert: 'primary', notice: 'success' }
    end

    def grade_item_status
      { inactive: 'light',
        success: 'success',
        resolved: 'info',
        unresolved: 'danger',
        error: 'error',
        no_submission: 'warning' }
    end
  end
end
