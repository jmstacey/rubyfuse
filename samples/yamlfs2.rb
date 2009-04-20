# yamlfs2.rb
#
# This yamlfs uses MetaDir instead of a single hash to do everything.
# It also includes properly functioning atime/mtime/ctime, using MetaDir,
# and only saves on exit.

require 'rubyfuse'
include RubyFuse

require 'yaml'

class YAMLFS < RubyFuse::MetaDir
  def initialize(filename)
    @filename = filename
    if File.exists?(@filename)
    else
      super()
    end
    begin
      x = YAML.load(IO.read(filename))
      @subdirs, @files, @times, @ctime, @mtime, @atime = x
    rescue Exception
      @fs = Hash.new()
    end
    at_exit { save }
  end
  def save
    File.open(@filename,'w') do |fout|
      dump = [ @subdirs, @files, @times, @ctime, @mtime, @atime ]
      fout.puts(YAML.dump(dump))
    end
  end
end

if (File.basename($0) == File.basename(__FILE__))
  if (ARGV.size != 2)
    puts "Usage: #{$0} <directory> <yamlfile>"
    exit
  end

  dirname, yamlfile = ARGV

  unless File.directory?(dirname)
    puts "Usage: #{dirname} is not a directory."
    exit
  end

  root = YAMLFS.new(yamlfile)

  # Set the root RubyFuse
  RubyFuse.set_root(root)

  RubyFuse.mount_under(dirname)

  RubyFuse.run # This doesn't return until we're unmounted.
end
