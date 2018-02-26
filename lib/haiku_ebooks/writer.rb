# frozen_string_literals: true

class HaikuEbooks::Writer

  # @option <max_links>Integer [read|write] The length of the Markov Chain
  #
  #   For `max_links = 2` up to the two previous words will be used to find the
  #   next word when writing.
  #
  # @option <writer>Symbol [write] Specify the writing style
  #
  #   Currently the only available value is `:haiku`.
  #
  DEFAULT_OPTIONS = {
    max_links: 2,
    writer: :haiku,
  }.freeze

  # Each of these answers the question "Is value `v` valid for this option?"
  OPTIONS_VALIDATORS = {
    max_links: ->(v) { v.is_a?(Integer) && v >= 0 },
    writer: ->(v) { v == :haiku },
  }.freeze

  MC_FILE = HaikuEbooks.data_path('db', 'persistent_markov_chain_file').freeze

  MC_DEPTH = 2

  LAST_QUERY = /[\.\?\!]['"]?$/.freeze

  FIRST_QUERY = /^[^[[:lower:]]]/.freeze

  def self.write(options={})
    new(options).write
  end

  def initialize(options={})
    @options = parse_options(options)
    @markov_chain = HaikuEbooks::PersistentMarkovChain.new(MC_FILE, MC_DEPTH)
  end

  def write(options={})
    opt = parse_options(options)
    send opt[:writer], opt
  end

  private

  def parse_options(options)
    opt = validate_options(options)
    DEFAULT_OPTIONS.merge(@options || {}).merge(opt)
  end

  def validate_options(options)
    # Get rid of unsupported options
    opts = options.select { |k, _| DEFAULT_OPTIONS.keys.include?(k) }
    # Get rid of options with invalid values
    opts.keys.each do |k|
      opts.delete(k) unless OPTIONS_VALIDATORS[k].call(opts[k])
    end
    opts
  end

  def haiku(opt)
    line_1 = five_line(**opt, before_word: [])
    before_word = line_1.last(opt[:max_links]).map(&:first)

    line_2 = seven_line(**opt, before_word: before_word)
    before_word = (line_1 + line_2).last(opt[:max_links]).map(&:first)

    line_3 = five_line(**opt, before_word: before_word, last: true)

    [line_1, line_2, line_3].map { |l| l.map(&:first).join(' ') }.join("\n")
  end

  def five_line(opt)
    if opt[:last]
      generic_line(5, opt[:max_links], opt[:before_word], false, true)
    else
      generic_line(5, opt[:max_links], opt[:before_word], true)
    end
  end

  def seven_line(opt)
    generic_line(7, opt[:max_links], opt[:before_word])
  end

  def generic_line(syllables, max_links, before_word, first=false, last=false)
    words = [random_word(before_word, syllables, last, first)]

    loop do
      chain_words = get_chain_words(before_word, words, max_links)
      words <<
        random_word(chain_words, syllables - syllable_count(words), last)

      # This line is finished
      return words if syllable_count(words) == syllables
    end
  end

  def syllable_count(words)
    words.inject(0) { |s, (_, i)| s + i}
  end

  def get_chain_words(before_word, words, max_links)
    (before_word + words.map(&:first)).last(max_links)
  end

  def random_word(words, max_syllables, last=false, first=false)
    weights = edges_from(words, max_syllables, last, first)

    while weights.empty?
      raise "Infinite Loop! #{max_syllables}" if words == []
      words = words[1..-1]
      weights = edges_from(words, max_syllables, last, first)
    end

    weights[rand(weights.length)]
  end

  def edges_from(words, max_syllables, last, first)
    @markov_chain.chain_from_words(words).select do |w|
      next false if w[1] > max_syllables
      next false if first && !(w[0] =~ FIRST_QUERY)
      next false if last && w[1] == max_syllables && !(w[0] =~ LAST_QUERY)
      true
    end
  end
end
