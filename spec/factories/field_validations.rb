# frozen_string_literal: true

FactoryBot.define do
  factory :length_field_validation, class: FieldValidation do
    association :field, factory: :string_field
    association :attribute_validation, factory: :length_attribute_validation
  end
end
