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

  describe '#create_customer' do
    it 'creates the customer' do
      user = create(:user_with_addresses, id: 500)
      kustomer = described_class.new(api_key: 'my_api_key')

      VCR.use_cassette('create_customer') do
        response = kustomer.create_customer(user)
        expect(response['attributes']['externalId']).to eq(user.id.to_s)
      end
    end
  end

  describe '#update_customer' do
    it 'updates the existing customer information on Kustomer' do
      user = create(:user, kustomer_id: 'the_customer_UUID')
      kustomer = described_class.new(api_key: 'my_api_key')

      user.update(email: 'the_new_email@example.com')

      VCR.use_cassette('update_customer') do
        new_customer_data = kustomer.update_customer(user)
        expect(new_customer_data['attributes']['emails'][0]['email']).to eq('the_new_email@example.com')
      end
    end
  end

  describe '#create' do
    context 'with well-formed custom attributes' do
      it 'creates the KObject for the customer' do
        kustomer = described_class.new(api_key: 'my_api_key')
        user = build_stubbed(:user, kustomer_id: 'the_customer_UUID')
        attributes = {
          'orderIdNum' => 1,
          'orderCreatedAt' => Time.zone.now,
          'orderNumberStr' => 'R11111111'
        }
        allow(kustomer).to receive(:find_customer)
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
        user = create(:user)
        attributes = {
          'notAnActualAttribute' => 'foobar'
        }
        allow(kustomer).to receive(:find_customer)
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

  describe '#find_customer' do
    context 'when the Spree::User has a kustomer_id' do
      it 'retrieves the customer via their UUID' do
        kustomer = described_class.new(api_key: 'my_api_key')
        user = create(:user, kustomer_id: 'the_customer_UUID')
        allow(kustomer).to receive(:find_customer_by_uuid)

        kustomer.find_customer(user)

        expect(kustomer).to have_received(:find_customer_by_uuid).with(user.kustomer_id)
      end
    end

    context 'when the Spree::User does not have a kustomer_id' do
      it 'retrieves the customer via their email' do
        kustomer = described_class.new(api_key: 'my_api_key')
        user = create(:user)
        allow(kustomer).to receive(:find_customer_by_email)
        allow(kustomer).to receive(:find_customer_by_external_id).and_return(nil)

        kustomer.find_customer(user)

        expect(kustomer).to have_received(:find_customer_by_email).with(user.email)
      end

      it 'retrieves the customer via their external_id when they cannot be found via email' do
        kustomer = described_class.new(api_key: 'my_api_key')
        user = create(:user)
        allow(kustomer).to receive(:find_customer_by_email).and_return(nil)
        allow(kustomer).to receive(:find_customer_by_external_id)

        kustomer.find_customer(user)

        expect(kustomer).to have_received(:find_customer_by_external_id).with(user.id)
      end
    end
  end

  describe '#find_customer_by_external_id' do
    context 'when querying for an existing customer' do
      it 'returns the customer KObject as an hash' do
        kustomer = described_class.new(api_key: 'my_api_key')
        user = build_stubbed(:user, id: 6)

        VCR.use_cassette('find_success') do
          customer = kustomer.find_customer_by_external_id(user.id)
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
          customer = kustomer.find_customer_by_external_id(user.id)
          expect(customer).to eq(nil)
        end
      end
    end
  end

  describe '#find_customer_by_email' do
    context 'when querying for an existing customer' do
      it 'returns the customer KObject as an hash' do
        kustomer = described_class.new(api_key: 'my_api_key')
        user = build_stubbed(:user, email: 'jdoe@example.com')

        VCR.use_cassette('find_by_email_success') do
          customer = kustomer.find_customer_by_email(user.email)
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
        user = build_stubbed(:user, email: 'not_a_customer@example.com')

        VCR.use_cassette('find_by_email_failure') do
          customer = kustomer.find_customer_by_email(user.email)
          expect(customer).to eq(nil)
        end
      end
    end
  end
end
