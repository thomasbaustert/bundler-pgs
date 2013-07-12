require "net/http"
require 'net/http/persistent'
require 'bundler/version'
require "bundler-pgs/credential_file"

unless ["1.3.5"].include?(Bundler::VERSION)
  puts "\nWarning: You are using bundler #{Bundler::VERSION} and bundler-pgs patch might not work for this version."
  puts "Make sure your Gemfile.lock does not contain your credentials after running pundle!"
  puts ""
end

##
# Patch of Ruby HTTP lib to use uri with credentials (e.g. http://user:password@...)
# instead of original uri (e.g. http://_:_@....) when calling #request.
#
class Net::HTTP::Persistent
  alias_method :orig_request, :request

  def request(uri, req = nil, &block)
    orig_request(::BundlerPatch::UriResolver.resolve(uri), req, &block)
  end
end

##
# Extend bundler DSL to allow using convenient method in Gemfile.
# This is optional and not really necessary.
#
# Examples:
#   source "https://rubygems.org"
#   private_gem_server
#   private_gem_server("fooserver")
#
module Bundler
  class Dsl
    include BundlerPatch::CredentialFile

    def private_gem_server(name = "default")
      with_credential_file do |credential_filename|
        yaml = YAML.load_file(credential_filename)
        yaml[name]["source"].to_s.strip
      end
    end

  end
end

##
# Replaces credential placeholder (e.g. http://_:_@....) with the credentials
# from the credentials file.
#
module BundlerPatch
  class UriResolver
    extend BundlerPatch::CredentialFile

    def self.resolve(uri)
      if uri_with_hidden_credentials?(uri)
        new_uri = uri_with_credentials(uri)
        Bundler.ui.debug "uri with credentials: '#{new_uri}'"
        new_uri
      else
        uri
      end
    end

    private

    ##
    # Return given url with credentials, e.g. +http://_:_@example.com+ to +http://gem:secret@gems.mycompany.com+.
    #
    # Example of file:
    #   ---
    #   default:
    #     source: "http://_:_@gems.mycompany.com"
    #     user: gem
    #     password: secret
    #
    def self.uri_with_credentials(orig_uri)
      new_uri = with_credential_file do |credential_filename|
        yaml = YAML.load_file(credential_filename)

        credential_key = orig_uri.user == "_" ? "default" : orig_uri.user
        credentials = yaml[credential_key]

        new_uri = orig_uri.dup
        new_uri.user     = credentials["user"].to_s.strip
        new_uri.password = credentials["password"].to_s.strip
        new_uri
      end

      new_uri || orig_uri
    end

    def self.uri_with_hidden_credentials?(uri)
      user_exists?(uri) && password_exists?(uri)
    end

    def self.user_exists?(uri)
      !uri.user.to_s.strip.empty?
    end

    def self.password_exists?(uri)
      !uri.password.to_s.strip.empty?
    end

  end

end
