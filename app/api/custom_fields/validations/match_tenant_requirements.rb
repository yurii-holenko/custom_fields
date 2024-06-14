module CustomFields
  module Validations
    class MatchTenantRequirements < Grape::Validations::Base
      def validate_param!(attr_name, params)
        # TODO: deal with type validation
        return if true

        fail Grape::Exceptions::Validation.new(
          **{
            params: [@scope.full_name(attr_name)],
            message: 'invalid'
          }
        )
      end
    end
  end
end
