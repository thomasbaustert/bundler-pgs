# Bundler Private Gem Server Patch

**This stuff is currently experimental!**

Patch for bundler to support credentials for sources that are not stored in Gemfile.lock.
Useful when running an additional private gem server besides rubygems.org.

Example:

    # Gemfile
    source "http://_:_@gems.mycompany.com"

    # Gemfile.lock
    GEM
      remote: https://rubygems.org/
      remote: http://_:_@gems.thomasbaustert.de/

## Warning

This comes with no warranty!

To prevent bundler from storing a source url to your private gem server with credentials I had to **patch** bundler.
See `lib/bundler-pgs/bundler_patch.rb` for details.

As long as the internal implementation of fetching a gem from an url does not change everything is fine.
In case a newer version of bundler change this code part the url might be stored in Gemfile.lock
with the credentials again.

Currently bundler version 1.3.5 is supported.

## Usage

Install the gem on **every** server using bundler, e.g. ci, staging and production:

    $ gem install bundler-pgs # pgs = private gem server :)

Add your private gem server url with `_` (underscore) as placeholder for the credentials:

    # Gemfile
    source "http://rubygems.org"
    source "http://_:_@gems.mycompany.com"

Add your credentials to `~/.gem/gemserver_credential` on **every** server using bundler, e.g. ci, staging and production:

    # ~/.gem/gemserver_credential
    ---
    default:
      source: "http://_:_@gems.mycompany.com"
      user: gem
      password: secret

Change mod:

    $ chmod 600 ~/.gem/gemserver_credential

Use the bundler patch by running `bundle-pgs` instead of `bundle`, e.g.:

    $ bundle-pgs install

This will load the patch and runs bundler as usual.

You will also need to change the bundle command for capistrano:

    # config/deploy.rb
    ...
    require "bundler/capistrano"
    set :bundle_cmd, "bundle-pgs"

## Caveats

* Does not work with [rubygems-bundler](https://github.com/mpapis/rubygems-bundler) and [bundler-unload](https://github.com/mpapis/bundler-unload) yet.

## Contact

For comments and question feel free to contact me: business@thomasbaustert.de

Copyright © 2013 [Thomas Baustert](http://thomasbaustert.de), released under the MIT license

