ENV["RAILS_ENV"] = 'test'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require File.expand_path("../../test/dummy/config/environment", __FILE__)

require 'openbill'

require 'pry'

require 'minitest/autorun'
require 'minitest/around/unit'

require 'database_cleaner'

DatabaseCleaner.strategy = :transaction
DatabaseCleaner.clean_with :truncation

Openbill.configure do |config|
  config.database = ActiveRecord::Base.connection.instance_variable_get('@config')
end

#MiniTest::TestCase.add_setup_hook { DatabaseCleaner.start }
#MiniTest::TestCase.add_teardown_hook { DatabaseCleaner.clean }

class OpenbillTest < Minitest::Test
  attr_reader :default_category, :default_policy

  def before_setup
    @default_category = Openbill.service.create_category 'test'
    @default_policy = Openbill.service.policies.insert name: 'Allow all'
  end

  def around(&tests)
    DatabaseCleaner.cleaning(&tests)
  end
end
