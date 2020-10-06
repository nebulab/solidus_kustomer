# frozen_string_literal: true

module SolidusKustomer
  class CreateCustomerJob < ApplicationJob
    queue_as :default

    def perform(user)
      SolidusKustomer.create_customer_now(user)
    end
  end
end
