require 'minitest/autorun'

require File.expand_path('../../lib/haiku_ebooks', __FILE__)

class TestHaikuEbooks < Minitest::Test

  # Share the syllable counter across tests
  HESC = HaikuEbooks::SyllableCounter.new

  {
    "duration,'": 3,
    "comma',": 2,
    "'distinguished'": 3,
    "Traffic!": 2,
    "distinguished": 3,
    "time again?' Here is a": 6,
    "test.'?>%$!'\" 'test": 2,
  }.each do |sym, syllables|
    word = sym.to_s
    define_method "test_#{word.inspect} has #{syllables} syllable" do
      assert_equal syllables, HESC.syllables(word.to_s)
    end
  end

end
