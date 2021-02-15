# frozen_string_literal: true

module Rubrics
  module Item
    # Rubric for executing a Java file.
    class Execute < Base
      class << self
        def default_criteria
          [
            { type: 'Rubrics::Criterion::Execute', action: :award }
          ]
        end

        def requirements
          [:filename]
        end
      end

      def run(filename, options)
        error = []

        # TODO: regexp does not work every time
        basename = File.basename(filename, '.*')
        # rubocop:disable Lint/MixedRegexpCaptureTypes
        /(public)?(\s+)?(class)\s+(?<classname>\w+)\s*{/ =~ File.read(filename)

        unless basename == classname
          error << I18n.t('rubrics.item.errors.execute.classname',
                          classname: classname,
                          filename: File.basename(filename))
        end

        stdin = options[:stdin]

        # Removes JAVA_TOOL_OPTIONS.
        # See https://devcenter.heroku.com/articles/java-support#environment
        capture = JDK.java(filename,
                           options[:arguments],
                           libraries: options[:libraries],
                           stdin: stdin,
                           timeout: options[:timeout])
                     .remove_line(:stderr, /.*JAVA_TOOL_OPTIONS.*/)

        stdout = capture.stdout
        stderr = capture.stderr
        exitstatus = capture.exitstatus

        error << I18n.t('rubrics.item.errors.execute.stderr') if stderr.present?
        error << I18n.t('rubrics.item.errors.execute.exitstatus', exitstatus: exitstatus) if exitstatus != 0

        expected_stdout = options[:stdout]

        if expected_stdout.present?
          regexp = expected_stdout.to_regexp

          # pattern is a string
          if regexp.nil?
            str_list = expected_stdout.split("\n")

            str_list.each do |str|
              if stdout.exclude?(str)
                error << I18n.t('rubrics.item.errors.execute.stdout.string', string: str, stdin: stdin)
              end
            end
          end

          # pattern is a regexp
          unless regexp.nil? || regexp.match?(stdout)
            error << I18n.t('rubrics.item.errors.execute.stdout.regexp', regexp: regexp.inspect, stdin: stdin)
          end
        end

        [capture, error]
      end
    end
  end
end
