# frozen_string_literal: true

# Make a Markov Chain
#
# chain = MarkovChain.new(0)
# chain.add_text("I know that you are special.")
# puts chain[0]
# #=> {[]=>["I", "know", "that", "you", "are", "special."]}
#
class HaikuEbooks::MarkovChain
  attr_reader :max_links

  def initialize(ml=2)
    @max_links = ml
    @markov_chains = []
    @files = []
    @@syllable_counter ||= HaikuEbooks::SyllableCounter.new
    init_ml
  end

  def [](index)
    fail RangeError, out_of_range_message(index) if index > max_links
    @markov_chains[index]
  end

  def []=(index, value)
    fail RangeError, out_of_range_message(index) if index > max_links
    @markov_chains[index] = value
  end

  def max_links=(ml)
    @max_links = ml
    init_ml
    ml
  end

  def add_text(text)
    @updated = true
    words = text.split(/\s+/)
    (0..max_links).each { |n| add_to_markov_chains(n, words) }
  end

  def add_text_from_filename(filename)
    return if @files.include?(filename)
    add_text(File.read(filename))
    @files << filename
  end

  # Get array of all words following `words`, which is an array of strings.
  def chain_from_words(words)
    self[words.length][words] || []
  end

  private

  def init_ml
    (0..@max_links).each { |i| @markov_chains[i] ||= {} }
  end

  def add_to_markov_chains(n, words)
    words.each_cons(n + 1) do |group|
      word = group[-1]
      self[n][group[0..-2]] ||= []
      self[n][group[0..-2]] << [word, @@syllable_counter.syllables(word)]
    end
  end

  def out_of_range_message(index)
    "Index [#{index}] is outside range (0..#{max_links})"
  end
end
