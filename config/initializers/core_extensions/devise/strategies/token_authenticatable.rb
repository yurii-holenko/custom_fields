module Devise
  module Strategies
    class TokenAuthenticatable < Devise::Strategies::Base
      def valid?
        header_auth? || param_auth?
      end

      def store?
        false
      end

      def authenticate!
        extract_token
        resource = mapping.to.find_by!(authentication_token: @extracted_token)
        resource.after_token_authentication
        success! resource
      rescue StandardError => e
        fail e.try(:message)
      end

      private

      def extract_token
        if header_auth?
          strategy, token = request.headers['Authorization'].split(' ')
          token_authorization_error('Malformed header, missing bearer') unless
            correct_strategy(strategy)
        else
          token = request.params[:token]
        end

        claim = claim(token)
        token_authorization_error('Unable to decode header or signature has expired') unless claim

        @extracted_token = claim['token']
      end

      def claim(token)
        JWT.decode(
          token,
          Rails.application.credentials.secret_key_base,
          true,
          algorithm: 'HS256'
        ).first
      rescue StandardError => _e
        nil
      end

      def token_authorization_error(message)
        raise TokenAuthorizationError.new(message)
      end

      def correct_strategy(strategy)
        (strategy || '').downcase == 'bearer'
      end

      def header_auth?
        request.headers['Authorization'].present?
      end

      def param_auth?
        request.params[:token].present?
      end
    end
  end
end

class TokenAuthorizationError < StandardError; end
