# Bundler Private Gem Server Patch

**This stuff is currently experimental!**

Patch for bundler to support credentials for sources that are not stored in Gemfile.lock.

Useful when running an additional private gem server besides rubygems.org.

## Warning

This comes with no warranty!

To prevent bundler from storing a source url to your private gem server with credentials I had to **patch** bundler.

As long as the internal implementation of fetching a gem from an url does not change everything is fine.
In case a newer version of bundler change this code part the url might be stored in Gemfile.lock
with the credentials again.

Currently bundler version 1.3.5 is supported.

## Usage

Install the gem on **every** server using bundler, e.g. ci, staging and production!:

    $ gem install bundler-pgs # pgs = private gem server :)

Add your private gem server url with placeholders for the credentials:

    # Gemfile
    source "http://rubygems.org"
    source "http://_:_@gems.mycompany.com"

Add your credentials to `~/.gem/gemserver_credential` on **every** server using bundler, e.g. ci, staging and production!:

    # ~/.gem/gemserver_credential
    ---
    default:
      source: "http://_:_@gems.mycompany.com"
      user: gem
      password: secret

Change mod:

    $ chmod 600 ~/.gem/gemserver_credential

Use the bundler patch by running `pundle` instead of `bundle`, e.g.:

    $ pundle install

This will load the patch and runs bundler as usual.

You will also need to change the bundle command for capistrano:

    # config/deploy.rb
    ...
    require "bundler/capistrano"
    set :bundle_cmd, "pundle"

## Contact

For comments and question feel free to contact me: business@thomasbaustert.de

Copyright © 2013 [Thomas Baustert](http://thomasbaustert.de), released under the MIT license

