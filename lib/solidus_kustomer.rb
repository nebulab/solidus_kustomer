# frozen_string_literal: true

require 'httparty'
require 'solidus_core'
require 'solidus_support'

require 'solidus_kustomer/version'
require 'solidus_kustomer/engine'
require 'solidus_kustomer/configuration'
require 'solidus_kustomer/errors'
require 'solidus_kustomer/client'
require 'solidus_kustomer/serializer/base'
require 'solidus_kustomer/serializer/user'

module SolidusKustomer
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    def create_customer_now(user)
      kustomer_client.create_customer(user)
    end

    def create_customer_later(user)
      SolidusKustomer::CreateCustomerJob.perform_later(user)
    end

    def update_customer_now(user)
      kustomer_client.update_customer(user)
    end

    def update_customer_later(user)
      SolidusKustomer::UpdateCustomerJob.perform_later(user)
    end

    private

    def kustomer_client
      @kustomer_client ||= SolidusKustomer::Client.new(api_key: configutation.api_key)
    end
  end
end
