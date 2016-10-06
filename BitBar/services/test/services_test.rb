$:.unshift __dir__ + '/../lib'

require 'minitest/autorun'
require 'services'

class ServicesTest < MiniTest::Unit::TestCase
  def test_format_duration
    assert_format "0s", 0
    assert_format "1s", 1 * 1000
    assert_format "59s", 59 * 1000
    assert_format "1m", 60 * 1000
    assert_format "1m", 61 * 1000
    assert_format "59m", 59 * 60 * 1000
    assert_format "1h", (3600) * 1000
    assert_format "1h", (3600 + 1) * 1000
    assert_format "1d", (24 * 3600 + 60 * 60) * 1000
    assert_format "2d", (2 * 24 * 3600 + 60 * 60) * 1000
  end

private

  def assert_format(result, i)
    assert_equal result, Services.format_duration(i)
  end
end
