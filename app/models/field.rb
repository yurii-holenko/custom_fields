# frozen_string_literal: true

class Field < ApplicationRecord
  belongs_to :tenant
  has_many :field_validations
  has_many :attribute_validations, through: :field_validations
  validates :name, presence: true, uniqueness: { scope: :tenant_id }
end
