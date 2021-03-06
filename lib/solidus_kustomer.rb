# frozen_string_literal: true

require 'httparty'
require 'solidus_core'
require 'solidus_support'

require 'solidus_kustomer/version'
require 'solidus_kustomer/engine'
require 'solidus_kustomer/configuration'
require 'solidus_kustomer/errors'
require 'solidus_kustomer/client'

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
