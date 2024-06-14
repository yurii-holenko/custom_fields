# frozen_string_literal: true

require 'grape_logging'

class Base < Grape::API
  before do
    header['Access-Control-Allow-Origin'] = '*'
    header['Access-Control-Request-Method'] = '*'
    header['Accept'] = 'application/json'
  end

  route :any, '*path' do
    error!(
      {
        error: I18n.t('exception_handlers.routing_error.error'),
        detail: I18n.t('exception_handlers.routing_error.details', path: request.path),
        status: I18n.t('exception_handlers.routing_error.status')
      },
      404
    )
  end

  content_type :json, 'application/json'

  # version 'v1', using: :path
  format :json
  default_format :json

  include ExceptionHandlers
  include Helpers
  include Constraints
end
