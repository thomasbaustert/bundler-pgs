# Bundler Private Gem Server

Patch for bundler to support credentials for sources that are not stored in `Gemfile.lock`.
Useful when running an additional private gem server besides `rubygems.org`.

Example:

    # Gemfile
    source "https://rubygems.org/"
    source "http://_:_@gems.mycompany.com" do
      ...
    end  

    # Gemfile.lock
    GEM
      remote: https://rubygems.org/
      remote: http://_:_@gems.mycompany.com/ (not http://user:password@gems.mycompany.com)

## Warning

This comes with no warranty!

To prevent bundler from storing a source url to your private gem server with credentials 
I **patched** bundler. See `lib/bundler-pgs/bundler_patch.rb` for details.

`bundle-pgs` will raise an exception in case the patched class and method does not exist
in `bundler`anymore.

## Usage

Install the gem on **every** server using bundler, e.g. ci, staging and production:

    $ gem install bundler-pgs

Exclude script `bundle-pgs` from `NOEXEC`:

    $ export NOEXEC_EXCLUDE="bundle-pgs"

Or better:

    # .bashrc
    export NOEXEC_EXCLUDE="bundle-pgs"
    ...

Otherwise you will get strange errors when running `bundle-pgs`, for example:

    $ bundle-pgs
    ...
    Resolving dependencies...
    Could not find gem 'foo (>= 0) ruby' in the gems available on this machine.

Add your private gem server url with `_` (underscore) as placeholder for the credentials:

    # Gemfile
    source "https://rubygems.org"
    source "http://_:_@gems.mycompany.com" do 
      gem 'my_private_gem'
    end    

Add your credentials to `~/.gem/gemserver_credential` on **every** server using bundler,
e.g. ci, staging and production:

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

This loads bundler as usual and applies the patch.

You will also need to change the bundle command for Capistrano:

    # config/deploy.rb
    ...
    require "bundler/capistrano"
    set :bundle_cmd, "bundle-pgs"

## Contact

For comments and question feel free to contact me: business@thomasbaustert.de

Copyright by [Thomas Baustert](http://thomasbaustert.de), released under the MIT license

