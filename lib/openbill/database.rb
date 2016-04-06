module Openbill
  class Database
    MAX_CONNECTIONS         = 10

    def initialize(config)
      @db = Sequel.connect config, logger: logger, max_connections: MAX_CONNECTIONS
      @db.extension :pagination
      @db.extension :pg_hstore
    end

    delegate :logger, to: Rails
  end
end
