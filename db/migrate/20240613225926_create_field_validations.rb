# frozen_string_literal: true

class CreateFieldValidations < ActiveRecord::Migration[7.1]
  def change
    create_table :field_validations do |t|
      t.references :field
      t.references :attribute_validation
      t.timestamps
    end
  end
end
