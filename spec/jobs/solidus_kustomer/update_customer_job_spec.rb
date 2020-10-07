# frozen_string_literal: true

RSpec.describe SolidusKustomer::UpdateCustomerJob do
  it 'updates the user on Kustomer' do
    solidus_kustomer = class_spy(SolidusKustomer)
    stub_const('SolidusKustomer', solidus_kustomer)
    user = build_stubbed(:user)

    described_class.perform_now(user)

    expect(solidus_kustomer).to have_received(:update_customer_now).with(user)
  end
end
