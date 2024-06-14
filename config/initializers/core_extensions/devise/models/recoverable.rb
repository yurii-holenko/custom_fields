module Devise
  module Models
    module Recoverable
      protected

      def set_reset_password_token
        raw, enc = Devise.token_generator.generate(self.class, :reset_password_token, true)

        self.reset_password_token   = enc
        self.reset_password_sent_at = Time.now.utc
        save(validate: false)
        raw
      end
    end
  end
end
