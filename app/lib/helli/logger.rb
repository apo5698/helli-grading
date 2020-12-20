# frozen_string_literal: true

module Helli
  # Logger utility. Formatted using JSON.
  #
  # Format:
  #
  #   {
  #     "timestamp": "",
  #     "level": "",
  #     "class": "",
  #     "method": "",
  #     ... // custom tags go here
  #     "message": ""
  #   }
  #
  # Sample log:
  #
  #   {
  #     "timestamp": "2020-12-11T21:06:47.423708-05:00",
  #     "level": "INFO",
  #     "class": "GradingController",
  #     "method": "null",
  #     "user": "1",
  #     "course": "1",
  #     "assignment": "4"
  #     "message": "Start grading"
  #   }
  module Logger
    # Creates a new logger.
    # @param [Hash] tags custom tags
    # @return [::Logger] a Logger object
    def self.new(tags = {})
      caller = binding.of_caller(1)
      class_name = caller.eval('self.class.name')
      method_name = caller.eval('__method__')

      path = Rails.root.join('log', Rails.env, "#{Rails.env}_#{Time.zone.now.to_date}.log").to_s
      logger = ::Logger.new(path)
      logger.formatter = lambda { |severity, time, _, msg|
        formatter = {}
        formatter[:timestamp] = time.to_time.iso8601(6)
        formatter[:level] = severity
        formatter[:class] = class_name
        formatter[:method] = method_name
        formatter.merge!(tags)
        formatter[:message] = msg

        "#{formatter.to_json}\n"
      }

      ActiveSupport::TaggedLogging.new(logger)
    end
  end
end
