# frozen_string_literal: true

module ExceptionHandlers
  def self.included(base)
    base.instance_eval do
      rescue_from Grape::Exceptions::Base do |e|
        headers = if env['warden']&.user
                    { 'Authorization' => "bearer #{env['warden'].user.get_encoded_claim}" }
                  else
                    { 'Accept' => 'application/json' }
                  end
        Rack::Response.new(
          {
            error: {
              code: e.try(:code) || e[:status] || 422,
              message: e.try(:text) || e.message
            }
          }.to_json,
          e[:status],
          headers
        )
      end
    end
  end
end

class Error < Grape::Exceptions::Base
  attr_reader :code, :text

  def initialize(opts = {})
    @code = opts[:code] || 1000
    @text = opts[:text] || ''

    @status = opts[:status] || 400
    @message = @text
  end
end

class ValidationError < Error
  def initialize(errors)
    super code: 1000,
          text: errors,
          status: 422
  end
end

class NotAuthorizedError < Error
  def initialize
    super code: 1001,
          text: I18n.t('exception_handlers.not_authorized_error'),
          status: 401
  end
end

class InvalidTokenError < Error
  def initialize
    super code: 1002,
          text: I18n.t('exception_handlers.invalid_token_error'),
          status: 422
  end
end
