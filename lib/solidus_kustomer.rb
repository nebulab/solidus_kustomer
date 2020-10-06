# frozen_string_literal: true

require 'httparty'
require 'solidus_core'
require 'solidus_support'
require 'solidus_tracking'

require 'solidus_kustomer/version'
require 'solidus_kustomer/engine'
require 'solidus_kustomer/configuration'
require 'solidus_kustomer/errors'
require 'solidus_kustomer/client'
require 'solidus_kustomer/serializer/base'
require 'solidus_kustomer/serializer/user'

module SolidusKustomer
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end
end
