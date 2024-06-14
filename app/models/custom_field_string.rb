# frozen_string_literal: true

class CustomFieldString < CustomField
  def value
    string_value
  end

  def value=(str)
    self.string_value = str
  end
end
