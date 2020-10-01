# frozen_string_literal: true

module SolidusKustomer
  class Client
    class << self
      def from_config
        new(api_key: SolidusKustomer.configuration.api_key)
      end
    end

    def initialize(api_key:, url: 'https://api.kustomerapp.com/v1/')
      @api_key = api_key
      @url = url
    end

    # Create a new instance of a Kustomer Klass for a customer
    #
    # @param kobject_klass [String] the Klass name of the KObject to create
    # @param customer [Spree::User] the user whose id will own the created KObject
    #
    # @return [Boolean] whether the creation succeded or not
    def create(kobject_klass, attributes:, customer:)
      customer_id = find_customer_by_external_id(customer)['id']

      response = HTTParty.post(
        "#{@url}customers/#{customer_id}/klasses/#{kobject_klass}",
        body: {
          title: kobject_klass.capitalize,
          custom: attributes
        }.to_json,
        headers: headers
      )

      response.success? || raise(SolidusKustomer::CreateError)
    end

    # Finds the customer via the Solidus database id
    #
    # @param user [Spree::User] the user whose data we're looking for
    #
    # @return [Hash] the customer data
    def find_customer_by_external_id(user)
      response = HTTParty.get(
        "#{@url}customers/externalId=#{user.id}",
        headers: headers
      )

      response.parsed_response['data'] if response.success?
    end

    private

    def headers
      {
        'Authorization' => "Bearer #{@api_key}",
        'Content-Type' => 'application/json'
      }
    end
  end
end
