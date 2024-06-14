# frozen_string_literal: true

class CustomFieldSetter
  def initialize(user, field, value)
    @user = user
    @field = field
    @value = value
  end

  def perform
    validate_value
    return if @user.errors.any?

    custom_field = @user.custom_fields.find_or_initialize_by(field_id: @field.id, type: @field.custom_string_type)
    custom_field.value = @value
    custom_field.save
  end

  private

  def validate_value
    @field.attribute_validations.each do |validation|
      result = validation.validate(@value)

      @user.errors.add(@field.name.to_sym, result[:error]) unless result[:valid]
    end
  end
end
