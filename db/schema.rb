# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 20_240_613_225_926) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'attribute_validations', force: :cascade do |t|
    t.bigint 'tenant_id'
    t.string 'type'
    t.string 'value'
    t.string 'error_message'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['tenant_id'], name: 'index_attribute_validations_on_tenant_id'
  end

  create_table 'custom_fields', force: :cascade do |t|
    t.bigint 'user_id'
    t.bigint 'field_id'
    t.string 'type'
    t.string 'string_value'
    t.integer 'number_value'
    t.jsonb 'object_value'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['field_id'], name: 'index_custom_fields_on_field_id'
    t.index ['user_id'], name: 'index_custom_fields_on_user_id'
  end

  create_table 'field_validations', force: :cascade do |t|
    t.bigint 'field_id'
    t.bigint 'attribute_validation_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['attribute_validation_id'], name: 'index_field_validations_on_attribute_validation_id'
    t.index ['field_id'], name: 'index_field_validations_on_field_id'
  end

  create_table 'fields', force: :cascade do |t|
    t.bigint 'tenant_id'
    t.string 'name'
    t.string 'type'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['name'], name: 'index_fields_on_name'
    t.index ['tenant_id'], name: 'index_fields_on_tenant_id'
  end

  create_table 'tenants', force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'users', force: :cascade do |t|
    t.string 'email', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.integer 'sign_in_count', default: 0, null: false
    t.datetime 'current_sign_in_at'
    t.datetime 'last_sign_in_at'
    t.string 'current_sign_in_ip'
    t.string 'last_sign_in_ip'
    t.string 'authentication_token'
    t.string 'refresh_token'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.bigint 'tenant_id'
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
    t.index ['tenant_id'], name: 'index_users_on_tenant_id'
  end
end
