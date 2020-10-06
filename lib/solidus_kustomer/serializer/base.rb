# frozen_string_literal: true

module SolidusKustomer
  module Serializer
    class Base
      attr_reader :object

      def initialize(object)
        @object = object
      end

      class << self
        def serialize(object)
          new(object).as_json
        end
      end

      def as_json(_options = {})
        raise NotImplementedError
      end

      def custom_attributes
        {}
      end
    end
  end
end
