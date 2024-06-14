require 'rails_helper'

describe ::CustomFields::Users do
  let(:email) { FFaker::Internet.email }
  let(:password) { 'Password@123' }

  describe 'POST#register' do
    let!(:tenant) { FactoryBot.create(:tenant) }
    context 'User registration success' do
      it 'create new user' do
        post '/api/users/register', **{
          params: {
            tenant_id: tenant.id,
            email: email,
            password: password
          }
        }
        expect_status(:created)
        expect_json_types(
          id: :integer,
          email: :string,
          created_at: :string,
          updated_at: :string
        )
        expect_json(
          email: email
        )
        expect(response.headers.has_key?('Authorization')).to be_truthy
      end
    end
    context 'with custom fields' do
      let!(:string_field) { FactoryBot.create(:string_field, tenant: tenant, name: 'address') }
      let!(:string_field_1) { FactoryBot.create(:string_field, tenant: tenant, name: 'address1') }
      it 'return custom fields' do
        post '/api/users/register', **{
          params: {
            tenant_id: tenant.id,
            email: email,
            password: password
          }
        }
        expect(json_body.key?(:address)).to be_truthy
        expect(json_body.key?(:address1)).to be_truthy
      end
    end
    context 'email not uniq' do
      let!(:user) { FactoryBot.create(:user, email: email) }
      it 'return error' do
        post '/api/users/register', **{
          params: {
            tenant_id: tenant.id,
            email: email,
            password: password
          }
        }
        expect_status(422)
        expect_json(
          error: { code: 1000, message: ['Email has already been taken'] }
        )
        expect(response.headers.has_key?('Authorization')).to be_falsey
      end
    end
    context 'password does not met requirements' do
      it 'return error' do
        post '/api/users/register', **{
          params: {
            tenant_id: tenant.id,
            email: email,
            password: '123'
          }
        }
        expect_status(422)
        expect_json(
          error: { code: 1000, message: ['Password is too short (minimum is 6 characters)'] }
        )
        expect(response.headers.has_key?('Authorization')).to be_falsey
      end
    end
  end
  describe 'POST#login' do
    context 'user login success' do
      let!(:user) { FactoryBot.create(:user, email: email, password: password) }
      it 'login user into application' do
        post '/api/users/login', **{
          params: {
            email: email,
            password: password,
          }
        }

        expect_status(:created)
        expect(response.headers.has_key?('Authorization')).to be_truthy
      end
    end
    context 'user does not exists' do
      it 'return error' do
        post '/api/users/login', **{
          params: {
            email: email,
            password: password,
          }
        }

        expect_status(401)
        expect_json(
          error: { code: 1001, message:  I18n.t('exception_handlers.not_authorized_error') }
        )
        expect(response.headers.has_key?('Authorization')).to be_falsey
      end
    end
    context 'password does not match' do
      let!(:user) { FactoryBot.create(:user, email: email, password: password) }
      it 'return error' do
        post '/api/users/login', **{
          params: {
            email: email,
            password: 'password',
          }
        }

        expect_status(401)
        expect_json(
          error: { code: 1001, message:  I18n.t('exception_handlers.not_authorized_error') }
        )
        expect(response.headers.has_key?('Authorization')).to be_falsey
      end
    end
  end
  describe 'DELETE#logout' do
    let!(:user) { FactoryBot.create(:user) }
    context 'successfully destroys users session' do

      it 'logout user from application' do
        delete '/api/users/logout', **{
          headers: authorization_header(user)
        }

        expect_status(:no_content)
        expect(request.env['warden'].user).to be(nil)
      end
    end
    context 'can not logout if authorization failed' do
      it 'return error' do
        delete '/api/users/logout', **{ headers: {'Authorization' => 'bearer token' } }

        expect_status(401)
        expect_json(
          error: { code: 1001, message:  I18n.t('exception_handlers.not_authorized_error') }
        )
      end
    end
  end
  describe 'PUT#update_password' do
    let(:email) { FFaker::Internet.email }
    let(:password) { 'Password@123' }
    let(:new_password) { 'Password@12345' }
    let(:weak_password) { '123456789' }
    let!(:user) { FactoryBot.create(:user, email: email, password: password) }

    context 'user successfully updates password' do
      it 'updates user password' do
        put '/api/users/update_password', **{
          headers: authorization_header(user),
          params: { password: new_password }
        }
        expect_status(:no_content)
        user.reload
        expect(user.valid_password?(new_password)).to be_truthy
        expect(user.valid_password?(password)).to be_falsey
      end
    end
    context 'weak password' do
      it 'return error' do
        put '/api/users/update_password', **{
          headers: authorization_header(user),
          params: { password: weak_password }
        }
        expect_status(400)
        expect_json(
          error: { code: 400, message: 'password is invalid' }
        )
        user.reload
        expect(user.valid_password?(password)).to be_truthy
      end
    end
  end
  describe 'POST#refresh_session' do
    let!(:user) { FactoryBot.create(:user) }
    let(:valid_refresh_token) { user.refresh_token }

    context 'when token is valid' do
      it 'responds with the Authorization bearer token and refresh user token' do
        post '/api/users/refresh_session', **{
          params: {
            token: valid_refresh_token,
          }
        }

        expect_status(:created)
        expect(response.headers.has_key?('Authorization')).to be_truthy

        # Updates the refresh_token so the new one is not the equal old one
        expect(valid_refresh_token).not_to eq(user.reload.refresh_token)
      end
    end

    context 'when user does not exists' do
      let(:refresh_token_for_non_existing_user) { '123' }

      it 'returns an error' do
        post '/api/users/refresh_session', **{
          params: {
            token: refresh_token_for_non_existing_user,
          }
        }

        expect_status(404)
        expect_json(
          error: { code: 1012, message: I18n.t('exception_handlers.user_not_found_error') }
        )
        expect(response.headers.has_key?('Authorization')).to be_falsey
      end
    end
  end
  describe 'PUT#profile' do
    let(:tenant) { FactoryBot.create(:tenant) }
    let!(:user) { FactoryBot.create(:user, tenant: tenant, email: 'mail@gmail.com') }
    let!(:string_field) { FactoryBot.create(:string_field, tenant: tenant, name: 'address') }

    context 'only tenant fields allowed' do
      it 'updates user with custom field value' do
        put '/api/users/profile', **{
          params: {
            custom_fields: {
              address: 'Kyiv, Khreshchatyk 11',
              address1: 'Kyiv, Khreshchatyk 11'
            }
          },
          headers: authorization_header(user)
        }

        expect_json(
          email: user.email,
          address: 'Kyiv, Khreshchatyk 11'
        )
      end
    end
    context 'respect value validation' do
      let(:length_validation) { FactoryBot.create(:length_attribute_validation, value: 5) }
      let!(:field_validation) do
        FactoryBot.create(:length_field_validation, field: string_field, attribute_validation: length_validation)
      end

      it 'return error' do
        put '/api/users/profile', **{
          params: {
            custom_fields: {
              address: 'Kyiv, Khreshchatyk 11'
            }
          },
          headers: authorization_header(user)
        }
        expect_json(
          error: { code: 1000, message: ['Address Must be 5 long'] }
        )
      end
    end
  end
end
