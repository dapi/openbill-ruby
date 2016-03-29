require 'singleton'

class Configuration
  DEFAULT_CURRENCY = 'USD'.freeze

  include Singleton

  attr_accessor :database

  attr_writer :default_currency

  def default_currency
    @default_currency || DEFAULT_CURRENCY
  end
end
