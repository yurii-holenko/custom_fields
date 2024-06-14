# frozen_string_literal: true

FactoryBot.define do
  factory :string_field, class: StringField do
    tenant
    name { 'address' }
  end
end
