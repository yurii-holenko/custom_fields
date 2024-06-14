# frozen_string_literal: true

class AttributeValidation < ApplicationRecord
  belongs_to :tenant, optional: true
end
