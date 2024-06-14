# frozen_string_literal: true

module Devise
  module Models
    module TokenAuthenticatable
      extend ActiveSupport::Concern

      TOKEN_EXPIRATION = 30.days
      TOKEN_THROTTLE_INTERVAL = 7.days

      included do
        before_create -> { update_auth_token; update_refresh_token }

        def get_encoded_claim(with_refresh_token = false)
          payload = payload(with_refresh_token)

          JWT.encode payload, Rails.application.credentials.secret_key_base
        end

        def payload(with_refresh_token)
          payload = {
            token: authentication_token,
            exp: TOKEN_EXPIRATION.from_now.to_i,
            domain: [:custom_fields]
          }

          payload[:refresh_token] = refresh_token if with_refresh_token
          payload
        end

        def random_token
          BCrypt::Password.create(SecureRandom.urlsafe_base64(nil, false))
        end

        def should_renew_auth_token
          return if within_grace_period?

          update_auth_token(should_save: true)
        end

        def update_auth_token(should_save: false)
          self.authentication_token = random_token
          save(validate: false) if should_save
        end

        def update_refresh_token(should_save: false)
          self.refresh_token = random_token
          save(validate: false) if should_save
        end

        def within_grace_period?
          sign_in_time = current_sign_in_at

          (sign_in_time ||= Time.now.utc) + TOKEN_THROTTLE_INTERVAL > Time.now.utc &&
            sign_in_time != created_at && !created_at.nil?
        end

        # A callback initiated after successfully authenticating. This can be
        # used to insert your own logic that is only run after the user successfully
        # authenticates.
        #
        # Example:
        #
        #   def after_token_authentication
        #     self.update_attribute(:invite_code, nil)
        #   end
        #
        def after_token_authentication; end
      end
    end
  end
end
