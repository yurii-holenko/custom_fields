# frozen_string_literal: true

FactoryBot.define do
  factory :length_attribute_validation, class: LengthAttributeValidation do
    tenant
    value { '5' }
    error_message { "Must be #{value} long" }
  end
end
