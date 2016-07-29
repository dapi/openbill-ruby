require 'test_helper'

class OpenbillUnitTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Openbill::VERSION
  end
end
