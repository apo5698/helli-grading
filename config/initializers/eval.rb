# frozen_string_literal: true

# rubocop:disable Rails/DynamicFindBy
# rubocop:disable Style/ClassAndModuleChildren
# rubocop:disable Style/Documentation

class ActiveStorage::Attached::Many
  # Finds an attachment by name.
  #
  # @param [String] name filename
  # @return [ActiveStorage::Attachment] attachment found
  def find_by_filename(name)
    attachments.find { |f| f.filename == name }
  end

  # Deletes an attachment by name.
  #
  # @param [String] name filename
  def delete_by_filename(name)
    find_by_filename(name).purge
  end
end

# class Symbol
#   # Supplies arguments for pretzel colon operator (&:).
#   #
#   #   [1, 2, 3, 4, 5].map(&:+.(1))
#   #   #=> [2, 3, 4, 5, 6]
#   #
#   #   [1, 2, 3, 4, 5].map(&:**.(2))
#   #   #=> [1, 4, 9, 16, 25]
#   def call(*args, &block)
#     ->(caller, *rest) { caller.send(self, *rest, *args, &block) }
#   end
# end

class Object
  # Returns all instance variables with their value of an object.
  #
  # @return [Hash] instance variables list
  def instance_variables_inspect
    instance_variables.reduce({}) do |hash, var|
      hash.merge(Hash[var.to_s.delete_prefix('@').to_sym, instance_variable_get(var)])
    end
  end
end

class String
  # Casts a string value to boolean.
  #
  # @return [Boolean] true or false
  def to_b
    ActiveModel::Type::Boolean.new.cast(downcase)
  end
end

class TrueClass
  # Returns true.
  #
  # @return [TrueClass] itself
  def to_b
    self
  end
end

class FalseClass
  # Returns false.
  #
  # @return [FalseClass] itself
  def to_b
    self
  end
end

class NilClass
  # Returns false.
  #
  # @return [FalseClass] false
  def to_b
    false
  end
end
