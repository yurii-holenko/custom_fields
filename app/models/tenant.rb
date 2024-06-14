# frozen_string_literal: true

class Tenant < ApplicationRecord
  has_many :users
  has_many :fields
end
