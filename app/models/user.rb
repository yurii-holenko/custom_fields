# frozen_string_literal: true

class User < ApplicationRecord
  PASSWORD_REGEXP = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.{8,64}).*\z/
  devise :database_authenticatable, :registerable, :trackable,
         :recoverable, :rememberable, :validatable, :token_authenticatable

  belongs_to :tenant
  has_many :custom_fields

  after_initialize :set_custom_attributes

  private

  def set_custom_attributes
    return unless tenant

    tenant.fields.each do |field|
      next if respond_to?(:"#{field.name}")

      define_singleton_method(:"#{field.name}", proc { custom_fields.find_by(field_id: field.id)&.value })
      define_singleton_method(:"#{field.name}=", proc { |value| CustomFieldSetter.new(self, field, value).perform })
    end
  end
end
