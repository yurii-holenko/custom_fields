# frozen_string_literal: true

class AddTenantToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference(:users, :tenant, index: true)
  end
end
