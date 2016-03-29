ENV["RAILS_ENV"] = 'test'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require File.expand_path("../../test/dummy/config/environment", __FILE__)

require 'openbill'

require 'minitest/autorun'
