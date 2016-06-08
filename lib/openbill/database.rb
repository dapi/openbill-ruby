module Openbill
  class Database
    def initialize(config)
      fail "Must be a Openbill::Configuration" unless config.is_a? Openbill::Configuration
      @db = Sequel.connect config.database, logger: config.logger, max_connections: config.max_connections
      @db.extension :pagination
      @db.extension :pg_hstore
    end

    attr_reader :db
  end
end
