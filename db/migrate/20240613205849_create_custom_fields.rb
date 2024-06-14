# frozen_string_literal: true

class CreateCustomFields < ActiveRecord::Migration[7.1]
  def change
    create_table :custom_fields do |t|
      t.references :user
      t.references :field
      t.string :type
      t.string :string_value
      t.integer :number_value
      t.jsonb :object_value
      t.timestamps
    end
  end
end
