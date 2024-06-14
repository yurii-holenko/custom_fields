# frozen_string_literal: true

module RequestHelper
  def authorization_header(user)
    { 'Authorization' => "bearer #{user.get_encoded_claim}" }
  end
end
