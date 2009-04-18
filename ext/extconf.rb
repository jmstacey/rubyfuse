# extconf.rb for Ruby FuseFS
#

# This uses mkmf
require 'mkmf'

# Prepare some default values for dir_config
include_default = nil
lib_default     = nil
if (RUBY_PLATFORM.include? "darwin") && (!find_library('fuse', 'main'))
  include_default = '/opt/local/include'
  lib_default     = '/opt/local/lib'
end

# This allows --with-fuse-dir, --with-fuse-lib, 
dir_config('fuse', include_default, lib_default)

# Add any fuse-[dir|lib] config options
if (with_config('fuse-dir'))
  $CPPFLAGS << ' -I' + with_config('fuse-dir')
end
if (with_config('fuse-lib'))
  $CPPFLAGS << ' -I' + with_config('fuse-lib')
end

unless have_library('fuse')
  puts "No FUSE library found!"
  exit
end

have_header('sys/statvfs.h') # OS X boxes have statvfs.h instead of statfs.h
have_header('sys/statfs.h')

# Create the makefile
create_makefile('fusefs_lib')