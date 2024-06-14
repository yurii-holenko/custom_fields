# frozen_string_literal: true

Warden::Manager.after_set_user except: :fetch do |record, warden, options|
  if record.respond_to?(:should_renew_auth_token) && warden.authenticated?(options[:scope])
    record.should_renew_auth_token
  end
end
