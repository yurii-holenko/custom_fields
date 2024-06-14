# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    tenant
    email { FFaker::Internet.email }
    password { 'Password@123' }
  end
end
