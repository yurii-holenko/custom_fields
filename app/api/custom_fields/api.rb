# frozen_string_literal: true

module CustomFields
  class API < Base
    Grape::Middleware::Auth::Strategies.add(
      :custom_fields_token_authenticate, ::TokenAuthenticator, ->(options) { [options[:resource]] }
    )
    auth :custom_fields_token_authenticate, resource: :user

    include ::Helpers
    include CustomFields::Exceptions
    require_relative 'validations/match_tenant_requirements'

    # Models
    mount CustomFields::Users

    # include Overrides
    unless Rails.env.test?
      add_swagger_documentation base_path: '/api',
                                api_version: 'v1',
                                mount_path: 'docs',
                                hide_format: true,
                                hide_documentation_path: true,
                                swagger_endpoint_guard: 'route_setting :auth, disabled: true',
                                info: {
                                  title: 'CustomFields API',
                                  description: 'CustomFields API'
                                }
    end
  end
end
