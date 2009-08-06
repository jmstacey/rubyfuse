RubyFuse
============

RubyFuse is a library aimed at allowing Ruby programmers to quickly and easily create virtual filesystems with little more than a few lines of code.

A "hello world" filesystem equivalent to the one demonstrated on fuse.sourceforge.org is just 20 lines of code!

RubyFuse is NOT a full implementation of the FUSE API ... yet.

Requirements
-------------

* Linux or Mac OS X
* FUSE or MacFuse
* Ruby 1.8
(* C compiler)

Install
-------------

RubyFuse is available as a Ruby Gem. Installation is as easy as:

    $ gem sources -a http://gems.github.com
    $ gem install jmstacey-rubyfuse

Manually installations can be performed with this:

    $ ruby setup.rb
		
More advanced installation options are available with setup.rb. Try "ruby setup.rb --help". If you need to supply alternative path information for the FUSE libraries, follow this example:

    $ ruby setup.rb config -- --with-fuse-dir=/opt/local/include --with-fuse-lib=/opt/local/lib
    $ ruby setup.rb setup
    $ sudo ruby setup.rb install

Usage
-------------

Some sample ruby filesystems are listed in "samples/". When you run a RubyFuse script, it will listen on a socket indefinitely, so either background the script or open another terminal to explore the filesystem.

API.markdown contains more usage information along with the official RDoc.

Copyright
------------
Copyright (c) 2005 Greg Millam.

Copyright (c) 2009 Jon Stacey. See LICENSE for details.