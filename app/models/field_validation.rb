# frozen_string_literal: true

class FieldValidation < ApplicationRecord
  belongs_to :field
  belongs_to :attribute_validation
end
