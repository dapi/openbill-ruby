require 'openbill/migration'
class CreateOpenbill < ActiveRecord::Migration
  include Openbill::Migration

  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"
    enable_extension "hstore"
    enable_extension "intarray"
    enable_extension "pg_trgm"
    enable_extension "uuid-ossp"
    openbill_up
  end

  def down
    openbill_down
  end
end
