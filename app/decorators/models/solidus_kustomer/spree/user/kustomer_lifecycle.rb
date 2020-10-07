# frozen_string_literal: true

module SolidusKustomer
  module Spree
    module User
      module KustomerLifecycle
        def self.prepended(base)
          base.after_commit :create_customer_on_creation, on: :create
          base.after_commit :update_customer_on_update, on: :update
        end

        private

        def create_customer_on_creation
          return unless SolidusKustomer.configuration.create_customer_on_user_creation

          SolidusKustomer.create_customer_later(self)
        end

        def update_customer_on_update
          return unless SolidusKustomer.configuration.update_customer_on_user_update

          SolidusKustomer.update_customer_later(self)
        end
      end
    end
  end
end

Spree.user_class.prepend(SolidusKustomer::Spree::User::KustomerLifecycle)
