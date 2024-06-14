# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:tenant) { FactoryBot.create(:tenant) }
  let!(:user) { FactoryBot.create(:user, tenant: tenant, email: 'mail@gmail.com') }

  describe 'custom_fields' do
    context 'string field type' do
      let(:expected_value) { 'Kyiv, Khreshchatyk 11' }
      let!(:string_field) { FactoryBot.create(:string_field, tenant: tenant, name: 'address') }
      let!(:custom_field) do
        FactoryBot.create(:string_custom_field, user: user, field: string_field, string_value: expected_value)
      end
      it 'add custom field to user' do
        initialized_user = User.find_by_email('mail@gmail.com')
        expect(initialized_user.respond_to?(:address)).to be_truthy
        expect(initialized_user.address).to eq(expected_value)
      end
    end

    describe 'custom field validation' do
      let(:default_value) { 'Kyiv, Khreshchatyk 11' }
      let(:length_validation) { FactoryBot.create(:length_attribute_validation, value: 5) }
      let(:string_field) { FactoryBot.create(:string_field, tenant: tenant, name: 'address') }
      let!(:field_validation) do
        FactoryBot.create(:length_field_validation, field: string_field, attribute_validation: length_validation)
      end
      # let!(:custom_field) { FactoryBot.create(:string_custom_field, user: user, field: string_field, string_value: default_value) }

      context 'invalid value' do
        it 'add error to user' do
          initialized_user = User.find_by_email('mail@gmail.com')
          initialized_user.address = default_value
          expect(initialized_user.errors.messages).to eq({ address: [length_validation.error_message] })
        end
      end

      context 'valid value' do
        let(:valid_value) { '12345' }
        it 'add error to user' do
          initialized_user = User.find_by_email('mail@gmail.com')
          initialized_user.address = valid_value
          expect(initialized_user.errors.messages).to eq({})
        end
      end
    end
  end
end
