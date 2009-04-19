# mp3stripfs.rb
#
# Filter mp3 file requests so that returned files have no id3v2 tags.
#
# License: Ruby
# Author: Justin Dossey (jbd@corp.podomatic.com)
# Website: http://www.podomatic.com

require 'fusefs'
include FuseFS

class Mp3StripFS < FuseFS::FuseDir
  def initialize(path)
    @basedir = path
  end
  def contents(path)
    Dir.entries("#{@basedir}#{path}") - ['.','..']
  end
  def executable?(path)
    false
  end
  def directory?(path)
    File.directory? "#{@basedir}#{path}"
  end
  def file?(path)
    File.file? "#{@basedir}#{path}"
  end

  # return the size of a file without the id3v2 header.
  # This leaks a little because if you check the size of a file, but never
  # open/close it, the @offsets hash will have an entry for that file 
  # forever.  It's not an issue for me because I have plenty of memory and
  # even with thousands of entries, @offsets will be relatively small.
  def size(path)
    if @offsets and @offsets[path]
      return File.size("#{@basedir}#{path}") - @offsets[path]
    else
      @offsets ||= {}
      File.open("#{@basedir}/#{path}") do |fd|
        @offsets[path] = seek_to_mpeg_start(fd)
        return File.size("#{@basedir}/#{path}") - @offsets[path]
      end
    end
  end

  # use the raw_* methods (thank you, Greg Millam) to keep memory footprint
  # reasonable.
  def raw_open(path,opts)
    @offsets ||= {}
    # We only care about reads.
    return false if opts != "r"
    @fcache ||= {}
    @ptrs ||= {}
    @fcache[path] = File.open("#{@basedir}/#{path}")
    @ptrs[path] = 0
    @offsets[path] ||= seek_to_mpeg_start(@fcache[path])
    
    # this next line may not be useful, but I like to return a file handle from 
    # a file opener.
    @fcache[path]
  end

  def raw_read(path, offset, size)
    if @ptrs[path] != offset
      @fcache[path].seek(@offsets[path]+offset, IO::SEEK_SET)
      @ptrs[path] = offset
    end
    @ptrs[path] += size 
    return @fcache[path].read(size)
  end

  def raw_close(path)
    @fcache[path].close
    @fcache.delete path
    @offsets.delete path
    @ptrs.delete path
  end


  private
  # seek to the start of the MPEG block.  
  # This is largely cribbed from Guillame Peirronet's Ruby mp3info library
  # at http://ruby-mp3info.rubyforge.org/
  def seek_to_mpeg_start(file)
    if file.read(3) == 'ID3'
      file.read(2) # skip the version
      file.read(1) # skip the flags
      size = file.read(4) # this is the tag size, excluding header.
      size_bytes = (size[0] << 21) + (size[1] << 14) + (size[2] << 7) + size[3] + 10
      file.seek(size_bytes, IO::SEEK_SET)
      # now find the mpeg header.  Should be right away, but there is the 
      # possibility that the headers lied, or the id3v2.4 spec has a footer 
      # that is not included in the size from the header.
      loop do 
        if file.getc == 0xff
          break if file.eof?
          data = file.read(3)
          break if file.eof?
          head = 0xff000000 + (data[0] << 16) + (data[1] << 8) + data[2]
          if check_head(head)
            file.seek(-4, IO::SEEK_CUR)
            return file.tell
          else
            file.seek(-3, IO::SEEK_CUR)
          end
        end
      end
    else
      # This mp3 has no id3v2 header, or it is not an mp3
      file.rewind
    end
    file.tell
  end
  def check_head(head)
    return false if head & 0xffe00000 != 0xffe00000    # 11 bit MPEG frame sync
    return false if head & 0x00060000 == 0x00060000    #  2 bit layer type
    return false if head & 0x0000f000 == 0x0000f000    #  4 bit bitrate
    return false if head & 0x0000f000 == 0x00000000    #        free format bitstream
    return false if head & 0x00000c00 == 0x00000c00    #  2 bit frequency
    return false if head & 0xffff0000 == 0xfffe0000
    true
  end
end

# the following is boilerplate from other fusefs examples.
if (File.basename($0) == File.basename(__FILE__))
  if (ARGV.size != 2)
    puts "Usage: #{$0} <mountdir> <mp3dir>"
    puts
    puts "  This will mount mp3stripfs on <mountdir>, creating an effective"
    puts "  mirror of <mp3dir>, with mp3 tags stripped."
    exit
  end

  dirname = ARGV.shift
  basepath = ARGV.shift

  unless File.directory?(dirname)
    puts "Usage: #{dirname} is not a directory."
    exit
  end

  unless File.directory?(basepath)
    puts "Usage: #{basepath} is not a directory."
    exit
  end

  root = Mp3StripFS.new(basepath)

  # Set the root FuseFS
  FuseFS.set_root(root)

  FuseFS.mount_under(dirname)

  FuseFS.run # This doesn't return until we're unmounted.
end

