require 'openbill/migration'

class AddOpenbill < ActiveRecord::Migration
  include Openbill::Migration
end
