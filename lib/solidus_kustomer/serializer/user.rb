# frozen_string_literal: true

module SolidusKustomer
  module Serializer
    class User < SolidusKustomer::Serializer::Base
      def user
        object
      end

      def as_json
        {
          'name' => name_builder(user.bill_address || user.ship_address),
          'username': user.email,
          'emails' => [
            {
              'type' => 'home',
              'email' => user.email,
            },
          ],
          'externalId' => user.id.to_s,
        }.merge(custom_attributes).compact
      end

      private

      def name_builder(address)
        return unless address

        address.respond_to?(:name) ? address.name : "#{address.first_name} #{address.last_name}"
      end
    end
  end
end
