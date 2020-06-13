require 'colorize'

module ApplicationHelper
  # Sample output:
  #   Upload HelloWorld.java (in green) from /users/user1/exercises/1/src (in yellow)
  #   Delete /users/user1/exercises/1/test/Test.java (in green)
  #   Delete /users/abc/projects/3/src (in yellow)
  def self.log_action(action:, from:, to: nil)
    dir = %r{(/.+)}
    from = from.to_s.match(dir) ? relpath(from).yellow : relpath(from).green
    to = to.to_s.match(dir) ? relpath(to).yellow : relpath(to).green unless to.nil?
    puts "#{action.capitalize} #{from}#{to.nil? ? '' : " => #{to}"}"
  end

  # Returns the relative path to +RAILS_ROOT/public/uploads+
  def self.relpath(path)
    path.to_s.gsub(Rails.root.join('public', 'uploads').to_s, '')
  end
end
