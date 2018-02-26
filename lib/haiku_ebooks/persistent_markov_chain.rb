# frozen_string_literal: true

# Make a Markov Chain that is saved to disk
#
# chain = PersistentMarkovChain.new('path/to/save/file', 0)
# chain.add_text("Here's an example.")
# puts chain[0]
# #=> {[]=>["Here's", "an", "example."]}
# chain.save
# ...
# chain = PersistentMarkovChain.new('path/to/save/file')
# puts chain[0]
# #=> {[]=>["Here's", "an", "example."]}
#
class HaikuEbooks::PersistentMarkovChain < HaikuEbooks::MarkovChain

  require 'msgpack'

  def initialize(path, ml=2)
    @path = path

    if seeded?
      load_from_file
    else
      super(ml)
      seed
    end
  end

  def save
    return unless @updated
    File.open(@path, 'wb') do |f|
      f.write [@max_links, @markov_chains, @files].to_msgpack
    end
  end

  private

  def seeded?
    File.exists?(@path)
  end

  def seed
    starttime = Time.now

    paths = HaikuEbooks.data_path('text', '*.txt')
    STDOUT.puts paths

    Dir[paths].each do |fn|
      STDOUT.puts "Seeding from #{fn}"
      add_text_from_filename(fn)
    end

    STDOUT.puts "Saving markov chain file"
    save

    STDOUT.puts "Seeding took #{Time.now - starttime}s"
  end

  def load_from_file
    STDOUT.puts "Loading MC from: #{@path}"
    file = File.new(@path, 'rb').read
    @max_links, @markov_chains, @files = MessagePack.unpack(file)
    @updated = false
    STDOUT.puts "MC Loaded from file: #{@path}"
  end

end
