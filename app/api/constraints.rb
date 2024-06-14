# frozen_string_literal: true

module Constraints
  class << self
    def included(base)
      apply_rules!
      base.use Rack::Attack
    end

    def apply_rules!
      # Rack::Attack.blocklist('Block API access from other ip if trusted ip set ') do |req|
      #   req.env['api.token'] && !req.env['api.token'].allow_ip?(req.ip)
      # end

      # Rack::Attack.throttle('req/ip', limit: 300, period: 5.minutes) do |req|
      #   req.ip
      # end
    end
  end
end
