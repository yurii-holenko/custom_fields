module Devise
  module Models
    module Confirmable
      def confirm(args = {})
        pending_any_confirmation do
          if confirmation_period_expired?
            period = Devise::TimeInflector.time_ago_in_words(self.class.confirm_within.ago)
            errors.add(:email, :confirmation_period_expired, period: period)
            return false
          end

          self.confirmed_at = Time.now.utc
          self.confirmation_token = nil

          saved = if pending_reconfirmation?
                    skip_reconfirmation!
                    self.email = unconfirmed_email
                    self.unconfirmed_email = nil

                    # We need to validate in such cases to enforce e-mail uniqueness
                    save(validate: true)
                  else
                    save(validate: args[:ensure_valid] == true)
                  end

          after_confirmation if saved
          saved
        end
      end

      def generate_confirmation_token
        if confirmation_token && !confirmation_period_expired?
          @raw_confirmation_token = confirmation_token
        else
          self.confirmation_token = @raw_confirmation_token = Devise.primitive_token
          self.confirmation_sent_at = Time.now.utc
        end
      end
    end
  end
end
