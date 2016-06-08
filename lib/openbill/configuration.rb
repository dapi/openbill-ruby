require 'singleton'

class Configuration
  DEFAULT_CURRENCY = 'USD'.freeze
  MAX_CONNECTIONS = 10
  LOG_PATH = 'log/db.log'.freeze

  include Singleton

  attr_accessor :database

  attr_writer :logger, :default_currency, :max_connections

  def logger
    @logger || default_logger
  end

  def max_connections
    @max_connections || MAX_CONNECTIONS
  end

  def default_currency
    @default_currency || DEFAULT_CURRENCY
  end

  private

  def default_logger
    if defined? Rails
      Rails.logger
    else
      Logger.new LOG_PATH
    end
  end
end
