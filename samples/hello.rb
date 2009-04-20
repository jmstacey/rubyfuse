require 'rubyfuse'

class HelloDir
  def contents(path)
    ['hello.txt']
  end
  def size(path)
    read_file(path).size
  end
  def file?(path)
    path == '/hello.txt'
  end
  def read_file(path)
    "Hello, World!\n"
  end
end

hellodir = HelloDir.new
RubyFuse.set_root( hellodir )

# Mount under a directory given on the command line.
RubyFuse.mount_under ARGV.shift
RubyFuse.run
