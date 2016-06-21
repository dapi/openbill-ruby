module Openbill
  class Database < ActiveRecord::Base
    establish_connection Openbill.config.database
  end
end
