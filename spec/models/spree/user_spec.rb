# frozen_string_literal: true

RSpec.describe Spree::User do
  describe '#save' do
    context 'when create_customer_on_creation is set to true' do
      it 'creates the newly created user on Kustomer' do
        allow(SolidusKustomer.configuration).to receive(:create_customer_on_user_creation)
          .and_return(true)

        user = create(:user)

        expect(SolidusKustomer::CreateCustomerJob).to have_been_enqueued.with(user)
      end
    end

    context 'when create_customer_on_creation is not set' do
      it 'does not create the newly created user on Kustomer' do
        allow(SolidusKustomer.configuration).to receive(:create_customer_on_user_creation)
          .and_return(nil)

        create(:user)

        expect(SolidusKustomer::CreateCustomerJob).not_to have_been_enqueued
      end
    end

    context 'when update_customer_on_update is set to true' do
      it 'updates the updated user on Kustomer' do
        allow(SolidusKustomer.configuration).to receive(:update_customer_on_user_update)
          .and_return(true)

        user = create(:user, email: 'jdoe@example.com')
        user.update!(email: 'jdoes_new_email@example.com')

        expect(SolidusKustomer::UpdateCustomerJob).to have_been_enqueued.with(user)
      end
    end

    context 'when update_customer_on_creation is not set' do
      it 'does not update the updated user on Kustomer' do
        allow(SolidusKustomer.configuration).to receive(:update_customer_on_user_update)
          .and_return(nil)

        user = create(:user, email: 'jdoe@example.com')
        user.update!(email: 'jdoes_new_email@example.com')

        expect(SolidusKustomer::UpdateCustomerJob).not_to have_been_enqueued
      end
    end
  end
end
