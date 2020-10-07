# frozen_string_literal: true

module SolidusKustomer
  class Configuration
    attr_accessor :api_key, :create_customer_on_user_creation, :update_customer_on_user_update
  end
end
