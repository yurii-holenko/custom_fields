# frozen_string_literal: true

class LengthAttributeValidation < AttributeValidation
  def validate(attribute_value)
    return { valid: true } if attr_valid?(attribute_value)

    { valid: false, error: error_message }
  end

  private

  def attr_valid?(attribute_value)
    attribute_value&.length&.to_s == value
  end
end
