require 'colorize'

module ApplicationHelper
  # noinspection RubyResolve
  class Log
    def self.log1(action, target, newline: true)
      if newline
        puts "#{action.bold} #{_colorize(target)}"
      else
        print "#{action.bold} #{_colorize(target)}"
      end
    end

    def self.log2(action, from, to, newline: true)
      if newline
        puts "#{action.bold} #{_colorize(from)} -> #{_colorize(to)}"
      else
        print "#{action.bold} #{_colorize(from)} -> #{_colorize(to)}"
      end
    end

    def self._colorize(str)
      str = str.to_s
      if File.file?(str)
        str.green
      elsif File.directory?(str)
        str.yellow
      else
        str.magenta
      end
    end

    private_class_method(:_colorize)
  end
end
