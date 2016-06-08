require 'openbill/configuration'

module Openbill
  class Database
    def initialize(config)
      fail "Must be a Openbill::Configuration (#{config.class})" unless config.is_a? Configuration
      @db = Sequel.connect config.database, logger: config.logger, max_connections: config.max_connections
      @db.extension :pagination
      @db.extension :pg_hstore
    end

    attr_reader :db
  end
end
