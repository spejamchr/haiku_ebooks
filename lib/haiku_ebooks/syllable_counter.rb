# frozen_string_literals: true

# Count the syllables in a word. Only used when reading text.
#
# Each instance of this class loads a mini version of the CMU Dictionary into
# memory, so only use when necessary.
#
# Based on https://github.com/sj26/syllable
#
class HaikuEbooks::SyllableCounter

  # special cases: 1 syllable less than expected
  SUBTRACTIONS = [
    /[^aeiou]e$/, # give, love, bone, done, ride ...
    /[aeiou](?:([cfghklmnprsvwz])\1?|ck|sh|[rt]ch)e[ds]$/,
    # (passive) past participles and 3rd person sing present verbs:
    # bared, liked, called, tricked, bashed, matched

    /.e(?:ly|less(?:ly)?|ness?|ful(?:ly)?|ments?)$/,
    # nominal, adjectival and adverbial derivatives from -e$ roots:
    # absolutely, nicely, likeness, basement, hopeless
    # hopeful, tastefully, wasteful

    /ion/, # action, diction, fiction
    /[ct]ia[nl]/, # special(ly), initial, physician, christian
    /[^cx]iou/, # illustrious, NOT spacious, gracious, anxious, noxious
    /sia$/, # amnesia, polynesia
    /.gue$/ # dialogue, intrigue, colleague
  ].freeze

  # special cases: 1 syllable more than expected
  ADDITIONS = [
    /i[aiou]/, # alias, science, phobia
    /[dls]ien/, # salient, gradient, transient
    /[aeiouym]ble$/, # -Vble, plus -mble
    /[aeiou]{3}/, # agreeable
    /^mc/, # mcwhatever
    /ism$/, # sexism, racism
    /(?:([^aeiouy])\1|ck|mp|ng)le$/, # bubble, cattle, cackle, sample, angle
    /dnt$/, # couldn/t
    /[aeiou]y[aeiou]/ # annoying, layer
  ].freeze

  PARSED_DICT = HaikuEbooks.data_path('db', 'cmudict-parsed.txt').freeze
  RAW_DICT = HaikuEbooks.data_path('cmudict-0.7b.txt').freeze

  def initialize
    parse_dict unless File.file?(PARSED_DICT)

    @words = Hash[File.read(PARSED_DICT).split("\n").map { |l|
      w, n = l.split(' ')
      [w, n.to_i]
    }]
  end

  def syllables(string)
    words = string.upcase.gsub("'", '').gsub(/[^A-Z]/, ' ').split(' ')

    # `words` can be empty when `string` has no letters`. This happens with
    # dates, for example. Let's disallow such "words" for haikus by giving them
    # 18 syllables (a haiku can only have 17 total).
    return 18 if words.empty?

    words.map { |word| single_word_syllables(word) }.inject(:+)
  end

  private

  def single_word_syllables(word)
    count = @words[word]
    return count unless count.nil?

    maybe = guess(word)
    STDOUT.puts "Word not in dictionary: #{word.inspect}. " +
      "Guessed: #{maybe} syllables"
    @words[word] = maybe
  end

  def guess(word)
    return 1 if word.length == 1
    word = word.downcase

    syllables = word.scan(/[aeiouy]+/).length

    # special cases
    SUBTRACTIONS.each { |s| syllables -= 1 if s.match(word) }
    ADDITIONS.each { |a| syllables += 1 if a.match(word) }

    syllables = 1 if syllables < 1 # no vowels?
    syllables
  end

  def parse_dict
    words = {}

    # Parse the CMU Dictionary
    File.open(RAW_DICT) do |f|
      while line = f.gets
        line = line.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
        next if /^[^A-Z']/.match(line)

        word, syllables = line.split('  ')
        word = word.gsub(/\(\d+\)$/, '')
        next if /[^A-Z']/.match(word)

        word = word.gsub(/[^A-Z]/, '')
        words[word] ||= []
        words[word] << syllables.scan(/[012]/).count
      end
    end

    words.transform_values!(&:min)
    File.write(PARSED_DICT, words.map { |k, v| "#{k} #{v}"}.join("\n"))
  end
end
