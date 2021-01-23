# frozen_string_literal: true

module Rubrics
  module Item
    class BaseSerializer < ActiveModel::Serializer
      attributes :id, :type, :filename

      def type
        object.type.demodulize
      end
    end
  end
end
