module Devise
  class TokenGenerator
    def generate(klass, column, primitive = false)
      key = key_for(column)

      loop do
        raw = primitive ? Devise.primitive_token : Devise.friendly_token
        enc = OpenSSL::HMAC.hexdigest(@digest, key, raw)
        break [raw, enc] unless klass.to_adapter.find_first(column => enc)
      end
    end
  end
end
