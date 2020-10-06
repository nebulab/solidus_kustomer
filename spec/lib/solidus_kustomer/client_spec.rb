# frozen_string_literal: true

RSpec.describe SolidusKustomer::Client do
  describe '#headers' do
    it 'returns the headers with the expected parameters' do
      kustomer = described_class.new(api_key: 'my_api_key')

      headers = kustomer.send(:headers)

      expect(headers).to include(
        'Authorization' => 'Bearer my_api_key',
        'Content-Type' => 'application/json'
      )
    end
  end

  describe '#create' do
    context 'with well-formed custom attributes' do
      it 'creates the KObject for the customer' do
        kustomer = described_class.new(api_key: 'my_api_key')
        user = build_stubbed(:user)
        attributes = {
          'orderIdNum' => 1,
          'orderCreatedAt' => Time.zone.now,
          'orderNumberStr' => 'R11111111'
        }
        allow(kustomer).to receive(:find_customer_by_external_id)
          .with(user)
          .and_return(
            {
              'type' => 'customer',
              'id' => 'the_customer_UUID',
              'attributes' => {
                'username' => 'johndoe@example.com',
                'externalId' => user.id
              }
            }
          )

        VCR.use_cassette('create_success') do
          kustomer.create('order', attributes: attributes, customer: user)
        end

        expect(
          a_request(:post, "https://api.kustomerapp.com/v1/customers/the_customer_UUID/klasses/order")
        ).to have_been_made
      end
    end

    context 'with malformed custom attributes' do
      it 'raises a CreateError' do
        kustomer = described_class.new(api_key: 'my_api_key')
        user = build_stubbed(:user)
        attributes = {
          'notAnActualAttribute' => 'foobar'
        }
        allow(kustomer).to receive(:find_customer_by_external_id)
          .with(user)
          .and_return(
            {
              'type' => 'customer',
              'id' => 'the_customer_UUID',
              'attributes' => {
                'username' => 'johndoe@example.com',
                'externalId' => user.id
              }
            }
          )

        VCR.use_cassette('create_failure') do
          expect {
            kustomer.create('order', attributes: attributes, customer: user)
          }.to raise_error(SolidusKustomer::CreateError)
        end
      end
    end
  end

  describe '#find_customer_by_external_id' do
    context 'when querying for an existing customer' do
      it 'returns the customer KObject as an hash' do
        kustomer = described_class.new(api_key: 'my_api_key')
        user = build_stubbed(:user, id: 6)

        VCR.use_cassette('find_success') do
          customer = kustomer.find_customer_by_external_id(user)
          expect(customer).to include(
            'id' => 'the_customer_UUID',
            'type' => 'customer'
          )
        end
      end
    end

    context 'when querying for a non existent customer' do
      it 'returns nil' do
        kustomer = described_class.new(api_key: 'my_api_key')
        user = build_stubbed(:user, id: 9999)

        VCR.use_cassette('find_failure') do
          customer = kustomer.find_customer_by_external_id(user)
          expect(customer).to eq(nil)
        end
      end
    end
  end
end
