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

    # Creates a new customer on Kustomer
    #
    # @param user [Spree::User] the user to create on Kustomer
    #
    # @return [Hash] containing the newly created data on Kustomer
    def create_customer(user)
      response = HTTParty.post(
        "#{@url}customers",
        body: SolidusKustomer::Serializer::User.serialize(user).to_json,
        headers: headers
      )

      raise(SolidusKustomer::CustomerCreateError) unless response.success?

      user.update!(kustomer_id: response.parsed_response['data']['id'])
      response.parsed_response['data']
    end

    # Updates a customer on Kustomer
    #
    # @param user [Spree::User] the user to update on Kustomer
    #
    # @return [Hash] containing the updated Kustomer data or nil
    # if it attempts to update a customer without a kustomer_id
    def update_customer(user)
      return unless user.kustomer_id

      response = HTTParty.put(
        "#{@url}customers/#{user.kustomer_id}",
        body: SolidusKustomer::Serializer::User.serialize(user).to_json,
        headers: headers
      )

      raise(SolidusKustomer::CustomerUpdateError) unless response.success?

      response.parsed_response['data']
    end

    # Create a new instance of a Kustomer Klass for a customer
    #
    # @param kobject_klass [String] the Klass name of the KObject to create
    # @param customer [Spree::User] the user whose id will own the created KObject
    #
    # @return [Boolean] whether the creation succeded or not
    def create(kobject_klass, attributes:, customer:)
      customer_id = find_customer_id(customer)

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

    # Finds a customer via their Spree::User record. If the user does not have a kustomer_id
    # associated, it also updates the original record to cache the UUID.
    #
    # @param user [Spree::User] the customer we're looking for
    #
    # @return [Hash] the customer data or nil if not present
    def find_customer(user)
      return find_customer_by_uuid(user.kustomer_id) if user.kustomer_id

      customer = find_customer_by_email(user.email) || find_customer_by_external_id(user.id)
      user.update!(kustomer_id: customer['id']) if customer
      customer
    end

    # Finds a customer UUID via their Spree::User record. If the user does not have a kustomer_id
    # associated, it also updates the original record to cache the UUID.
    #
    # @param user [Spree::User] the customer's UUID we're looking for
    #
    # @return [String] the customer UUID or nil if not present
    def find_customer_id(user)
      return user.kustomer_id if user.kustomer_id

      customer = find_customer(user)
      user.update!(kustomer_id: customer['id']) if customer
      customer['id']
    end

    # Finds a customer via their Kustomer UUID
    #
    # @param uuid [String] the customer UUID
    #
    # @return [Hash] the customer data or nil if not present
    def find_customer_by_uuid(uuid)
      response = HTTParty.get(
        "#{@url}customers/#{uuid}",
        headers: headers
      )

      return response.parsed_response['data'] if response.success?
    end

    # Finds a customer via their Spree::User id
    #
    # @param external_id [Integer] the customer UUID
    #
    # @return [Hash] the customer data or nil if not present
    def find_customer_by_external_id(external_id)
      response = HTTParty.get(
        "#{@url}customers/externalId=#{external_id}",
        headers: headers
      )

      response.parsed_response['data'] if response.success?
    end

    # Finds a customer via their Spree::User email
    #
    # @param email [String] the customer UUID
    #
    # @return [Hash] the customer data or nil if not present
    def find_customer_by_email(email)
      response = HTTParty.get(
        "#{@url}customers/email=#{email}",
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
