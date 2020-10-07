# frozen_string_literal: true

RSpec.describe SolidusKustomer::Serializer::User do
  describe '.serialize' do
    it 'serialize the user data' do
      user = create(:user)

      expect(described_class.serialize(user)).to be_instance_of(Hash)
    end

    context 'when the user has addresses' do
      it 'also serialize their name' do
        user = create(:user_with_addresses)

        expect(described_class.serialize(user)).to have_key('name')
      end
    end
  end
end
