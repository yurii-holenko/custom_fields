# frozen_string_literal: true

class CreateAttributeValidations < ActiveRecord::Migration[7.1]
  def change
    create_table :attribute_validations do |t|
      t.references :tenant
      t.string :type
      t.string :value
      t.string :error_message
      t.timestamps
    end
  end
end
