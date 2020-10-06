# frozen_string_literal: true

module SolidusKustomer
  class UpdateCustomerJob < ApplicationJob
    queue_as :default

    def perform(user)
      SolidusKustomer.update_customer_now(user)
    end
  end
end
