# frozen_string_literal: true

include Pagy::Backend
module Helpers
  extend Grape::API::Helpers
  UUID_REGEXP = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
  ISO8601_DATETIME_REGEX = /^([+-]?\d{4}(?!\d{2}\b))((-?)((0[1-9]|1[0-2])(\3([12]\d|0[1-9]|3[01]))?|W([0-4]\d|5[0-2])(-?[1-7])?|(00[1-9]|0[1-9]\d|[12]\d{2}|3([0-5]\d|6[1-6])))([T\s]((([01]\d|2[0-3])((:?)[0-5]\d)?|24:?00)([.,]\d+(?!:))?)?(\17[0-5]\d([.,]\d+)?)?([zZ]|([+-])([01]\d|2[0-3]):?([0-5]\d)?)?)?)?$/

  params :pagination do
    optional :page,
             type: Integer,
             default: 1,
             values: 1..199,
             desc: 'Page offset to fetch.'
    optional :per_page,
             type: Integer,
             default: 10,
             desc: 'Number of results to return per page.',
             values: [10, 25, 50, 100, 200]
  end

  def paginate(collection)
    pagy, records = pagy(collection, items: params[:per_page] || 25, page: params[:page] || 1)

    header 'X-Total', pagy.count.to_s
    header 'X-Total-Pages', pagy.pages.to_s
    header 'X-Per-Page', pagy.items.to_s
    header 'X-Page', pagy.page.to_s
    header 'X-Next-Page', pagy.next.to_s
    header 'X-Prev-Page', pagy.prev.to_s

    records
  end

  def declared_params
    declared(params, include_missing: false).except(:page, :per_page)
  end

  # Authentication helpers
  def authenticator
    (@authenticator ||= env['warden']) # or raise NoAuthenticatorError
  end

  def apply_auth_header(user, with_refresh_token: true)
    header 'Authorization', "bearer #{user.get_encoded_claim(with_refresh_token)}"
  end

  def authenticate_user(user, preserve_refresh_token: false)
    user.update_refresh_token(should_save: true) unless preserve_refresh_token
    authenticator.set_user(user, scope: :user)
    apply_auth_header(user, with_refresh_token: !preserve_refresh_token)
  end

  Devise.mappings.each_key do |mapping|
    define_method("current_#{mapping}") do
      authenticator.user(mapping)
    end
  end
end
