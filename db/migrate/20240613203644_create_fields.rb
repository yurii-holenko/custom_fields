# frozen_string_literal: true

class CreateFields < ActiveRecord::Migration[7.1]
  def change
    create_table :fields do |t|
      t.references :tenant
      t.string :name, index: true
      t.string :type

      t.timestamps
    end
  end
end
