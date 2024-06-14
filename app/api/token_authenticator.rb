# frozen_string_literal: true

class TokenAuthenticator
  attr_accessor :app, :env, :warden

  def initialize(app, resource_class)
    @app = app
    @resource_class = resource_class
  end

  def call(env)
    return @app.call(env) if env.blank?

    if !env['api.endpoint']&.route&.settings&.dig(:auth, :disabled)
      @warden ||= env['warden']
      # set default_scope coz Warden.authenticated? method calls 4 times
      @warden.config[:default_scope] = @resource_class
      @resource =
        @warden.user || @warden.authenticate(:token_authenticatable, scope: @resource_class)
      if @warden.authenticated?
        apply_authorization_header(*@app.call(env))
      else
        unauthorized
      end
    else
      @app.call(env)
    end
  end

  protected

  def apply_authorization_header(status, headers, response)
    auth_header = if @resource.respond_to?(:get_encoded_claim)
                    { 'Authorization' => "bearer #{@resource.get_encoded_claim}" }
                  else
                    {}
                  end

    [status, headers.merge(auth_header), response]
  end

  def unauthorized
    raise ::NotAuthorizedError
  end
end
