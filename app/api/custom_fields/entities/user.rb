# frozen_string_literal: true

module CustomFields
  module Entities
    class User < Grape::Entity
      format_with(:iso_timestamp, &:iso8601)

      expose :id, documentation: { type: 'String', desc: 'ID' }
      expose :email, documentation: { type: 'String', desc: 'Email' }
      expose :custom_attributes, merge: true
      with_options(format_with: :iso_timestamp) do
        expose :created_at, documentation: { type: String, desc: 'Created at, ISO8601' }
        expose :updated_at, documentation: { type: String, desc: 'Updated at, ISO8601' }
      end

      private

      def custom_attributes
        object.tenant.fields.each_with_object({}) do |field, memo|
          memo[field.name.to_sym] = object.send(field.name)
        end
      end
    end
  end
end
