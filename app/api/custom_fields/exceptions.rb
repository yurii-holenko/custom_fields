# frozen_string_literal: true

module CustomFields
  module Exceptions; end

  class UserNotFound < ::Error
    def initialize
      super code: 1012,
            text: I18n.t('exception_handlers.user_not_found_error'),
            status: 404
    end
  end
end
