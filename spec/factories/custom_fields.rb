# frozen_string_literal: true

FactoryBot.define do
  factory :string_custom_field, class: CustomFieldString do
    user
    association :field, factory: :string_field
    string_value { 'Kyiv, Khreshchatyk 11' }
  end
end
