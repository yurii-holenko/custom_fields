# frozen_string_literal: true

module CustomFields
  module Entities
    class Error < Grape::Entity
      expose :code, documentation: { type: 'Integer', desc: 'Internal error code' }
      expose :text, documentation: { type: 'String', desc: 'Error text' }
      expose :status, documentation: { type: 'Integer', desc: 'Http status code' }
    end
  end
end
