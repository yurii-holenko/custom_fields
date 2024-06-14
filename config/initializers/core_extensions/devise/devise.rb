module Devise
  def self.primitive_token(length = 8)
    "%0#{length}i" % SecureRandom.random_number(10**length)
  end
end
