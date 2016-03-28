require 'singleton'

class Configuration
  include Singleton

  attr_accessor :database_config
end
