# frozen_string_literal: true

SolidusKustomer.configure do |config|
  # Your Kustomer API key, in order to communicate with the Kustomer API.
  config.api_key = 'YOUR_KUSTOMER_API_KEY'

  # These options enable automatic customer lifecycle tracking for users on Kustomer.
  config.create_customer_on_user_creation = true
  config.update_customer_on_user_update = true
end
