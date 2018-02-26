
module HaikuEbooks

  # :stopdoc:
  ROOT_PATH = ::File.expand_path('../..', __FILE__) + ::File::SEPARATOR
  LIB_PATH = ::File.join(ROOT_PATH, 'lib') + ::File::SEPARATOR
  DATA_PATH = ::File.join(ROOT_PATH, 'data') + ::File::SEPARATOR
  VERSION = ::File.read(ROOT_PATH + 'version.txt').strip
  # :startdoc:

  # Returns the library path for the module. If any arguments are given,
  # they will be joined to the end of the libray path using
  # <tt>File.join</tt>.
  #
  def self.lib_path(*args)
    rv = args.empty? ? LIB_PATH : ::File.join(LIB_PATH, args.flatten)
    if block_given?
      begin
        $LOAD_PATH.unshift LIB_PATH
        rv = yield
      ensure
        $LOAD_PATH.shift
      end
    end
    return rv
  end

  # Returns the data path for the module. If any arguments are given,
  # they will be joined to the end of the libray path using
  # <tt>File.join</tt>.
  #
  def self.data_path(*args)
    rv = args.empty? ? DATA_PATH : ::File.join(DATA_PATH, args.flatten)
    if block_given?
      begin
        $LOAD_PATH.unshift DATA_PATH
        rv = yield
      ensure
        $LOAD_PATH.shift
      end
    end
    return rv
  end

  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path(*args)
    rv = args.empty? ? ROOT_PATH : ::File.join(ROOT_PATH, args.flatten)
    if block_given?
      begin
        $LOAD_PATH.unshift ROOT_PATH
        rv = yield
      ensure
        $LOAD_PATH.shift
      end
    end
    return rv
  end

  # Utility method used to require all files ending in .rb that lie in the
  # directory below this file that has the same name as the filename passed
  # in. Optionally, a specific _directory_ name can be passed in such that
  # the _filename_ does not have to be equivalent to the directory.
  #
  def self.require_all_libs_relative_to(fname, dir=nil)
    dir ||= ::File.basename(fname, '.*')
    search_me = ::File.expand_path(
      ::File.join(::File.dirname(fname), dir, '**', '*.rb'))

    Dir.glob(search_me).sort.each {|rb| require rb}
  end

end  # module HaikuEbooks

HaikuEbooks.require_all_libs_relative_to(__FILE__)
