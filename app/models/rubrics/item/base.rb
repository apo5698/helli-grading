# frozen_string_literal: true

module Rubrics
  module Item
    # A rubric contains multiple rubric items.
    class Base < ApplicationRecord
      self.table_name = :rubric_items

      ################
      # Associations #
      ################

      belongs_to :rubric

      has_many :criteria,
               dependent: :destroy,
               class_name: 'Rubrics::Criterion::Base',
               foreign_key: :rubric_item_id,
               inverse_of: :item

      has_many :grade_items,
               dependent: :destroy,
               foreign_key: :rubric_item_id,
               inverse_of: :rubric_item

      #############
      # Callbacks #
      #############

      # Initialize default criteria
      after_create do
        default_criteria.each { |c| criteria.create!(c) }
      end

      ###############
      # Delegations #
      ###############

      %i[basename description rules default_criteria requirements].each do |method|
        delegate method, to: :class
      end

      amoeba do
        enable
      end

      class << self
        # Returns the basename of the rubric item class.
        #
        # @return [String] basename
        def basename
          name.demodulize.to_s
        end

        # Returns the description of the rubric item.
        #
        # @return [String] usage
        def description
          I18n.t("rubrics.item.description.#{basename.underscore}")
        end

        # Returns the rules of the rubric item.
        #
        # @return [Hash] rules
        def rules
          I18n.t("rubrics.item.rule.#{basename.underscore}")
        end

        # Returns the default criteria for the rubric item.
        #
        # @return [Array<Hash>] default criteria list
        def default_criteria; end

        # Returns the requirements of the rubric item.
        # Available values:
        #   :filename, :file
        #
        # @return [Array<Symbol>]
        def requirements; end
      end

      def to_s
        "[#{basename}](#{filename || '?'})"
      end

      # Calculates the maximum points as per its awarding rubric criteria.
      #
      # @return [BigDecimal] points
      def maximum_points_possible
        criteria.reduce(0) { |sum, criterion| sum + (criterion.award? ? criterion.point : 0) }
      end

      def create_grade_items
        rubric.assignment.participants.each do |p|
          GradeItem.create_or_find_by!(participant_id: p.id, rubric_item_id: id)
        end

        GradeItem.where(rubric_item_id: id)
      end

      # Run grading on a file with options.
      #
      # @param [String] filename
      # @param [Hash] options
      # @return [Array] [[stdout, stderr, status], error_count]
      def run(filename, options) end
    end
  end
end
