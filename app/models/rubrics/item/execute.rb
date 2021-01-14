# frozen_string_literal: true

module Rubrics
  module Item
    # Rubric for executing a Java file.
    class Execute < Base
      class << self
        def default_criteria
          [
            { type: 'Rubrics::Criterion::Classname', action: :award, point: 1.0 },
            { type: 'Rubrics::Criterion::Execute', action: :award, point: 2.0 }
          ]
        end

        def requirements
          [:filename]
        end
      end

      def run(filename, options)
        opts = options.deep_dup

        lib = opt[:lib].transform_values(&:to_b)

        captures = Helli::Java.java(
          filename,
          junit: lib.delete(:enabled) && lib[:junit].to_b,
          args: opt[:args].delete(:enabled).to_b ? opt[:args][:java] : '',
          stdin: opt[:stdin].delete(:enabled).to_b ? opt[:stdin][:data] : '',
          timeout: opt[:timeout].delete(:enabled).to_b ? opt[:timeout][:timeout].to_i : 5
        )
        stderr = captures[1]

        if opt[:create].delete(:enabled).to_b
          c_filename = opt[:create][:filename]
          c_path = File.join(File.dirname(filename), c_filename)
          captures[0] << if File.exist?(c_path)
                           "\n[#{c_filename}]\n#{File.read(c_path)}"
                         else
                           "\n#{c_filename} not created"
                         end
        end

        error_count = 0
        # runtime errors
        error_count += 1 if stderr.include?('Exception in thread')
        # rare situation
        error_count += 1 if stderr.include?('java.lang.NoClassDefFoundError')

        [captures, error_count]
      end
    end
  end
end
