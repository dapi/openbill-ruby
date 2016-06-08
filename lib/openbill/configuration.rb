require 'singleton'

class Configuration
  DEFAULT_CURRENCY = 'USD'.freeze
  MAX_CONNECTIONS = 10

  include Singleton

  attr_accessor :database

  attr_writer :logger, :default_currency, :max_connections

  def logger
    @logger || Rails.logger
  end

  def max_connections
    @max_connections || MAX_CONNECTIONS
  end

  def default_currency
    @default_currency || DEFAULT_CURRENCY
  end
end
