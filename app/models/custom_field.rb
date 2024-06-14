# frozen_string_literal: true

class CustomField < ApplicationRecord
  belongs_to :user
  belongs_to :field
  validates :field_id, uniqueness: { scope: :user_id }
end
