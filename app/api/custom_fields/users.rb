# frozen_string_literal: true

module CustomFields
  class Users < Grape::API
    resource :users do
      helpers ::Helpers

      desc 'Sign up' do
        success CustomFields::Entities::User
        # failure?
      end
      route_setting :auth, disabled: true
      params do
        requires :tenant_id, type: Integer, desc: 'Tenant id'
        requires :email, type: String, desc: 'User email'
        requires :password, type: String, desc: 'Password'
      end
      post 'register' do
        user = User.create(declared_params)

        raise ::ValidationError, user.errors.full_messages unless user.valid?

        apply_auth_header(user)
        present user, with: CustomFields::Entities::User
      end

      desc 'Login' do
        success CustomFields::Entities::User
        failure [[401, I18n.t('exception_handlers.not_authorized_error'), CustomFields::Entities::Error]]
      end
      route_setting :auth, disabled: true
      params do
        requires :email, type: String, desc: 'Email'
        requires :password, type: String, desc: 'Password'
      end
      post 'login' do
        user = User.find_by(email: params[:email])
        raise ::NotAuthorizedError unless user&.valid_password?(params[:password])

        authenticate_user(user)
        present user, with: CustomFields::Entities::User
      end

      desc 'Logout'
      delete 'logout' do
        authenticator.logout(:user)
        authenticator.clear_strategies_cache!(scope: :user)
        body false
      end

      desc 'Update password' do
        failure [[422, 'Password Validation Errors (variable)', CustomFields::Entities::Error]]
      end
      params do
        requires :password, type: String, desc: 'Password', regexp: User::PASSWORD_REGEXP
      end
      put 'update_password' do
        unless current_user.update(password: params[:password])
          raise ::ValidationError, current_user.errors.full_messages
        end

        body false
      end

      desc 'Refresh User session using refresh token' do
        success CustomFields::Entities::User
        failure [[422, I18n.t('exception_handlers.invalid_token_error'), CustomFields::Entities::Error]]
      end
      route_setting :auth, disabled: true
      params do
        requires :token, type: String, desc: 'Refresh token'
      end
      post 'refresh_session' do
        user = User.find_by(refresh_token: declared_params[:token])
        raise UserNotFound unless user

        authenticate_user(user)
        present user, with: CustomFields::Entities::User
      end
    end
  end
end
