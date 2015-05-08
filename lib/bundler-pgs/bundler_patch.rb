require 'yaml'
require 'bundler'

module Bundler::Pgs
  class MonkeyPatchFailed < RuntimeError
    def message
      "bundler-pgs #{Bundler::Pgs::VERSION} failed to patch bundler #{Bundler::VERSION}. Cause: #{message}"
    end
  end
end

##
# Patches Bundler::RubygemsIntegration bundler to use url with the credentials.
#
raise Bundler::Pgs::MonkeyPatchFailed, "Bundler::RubygemsIntegration not defined anymore" unless defined?(Bundler::RubygemsIntegration)
raise Bundler::Pgs::MonkeyPatchFailed, "Bundler::RubygemsIntegration.download_gem not defined anymore" unless Bundler::RubygemsIntegration.new.respond_to?(:download_gem)

module Bundler
  class RubygemsIntegration
    def download_gem(spec, uri, path)
      new_uri = ::Bundler::Pgs::UriResolver.resolve(uri)
      Gem::RemoteFetcher.fetcher.download(spec, new_uri, path)
    end
  end
end

##
# Patches Bundler::Fetcher bundler to use url with the credentials.
#
raise Bundler::Pgs::MonkeyPatchFailed, "Bundler::Fetcher not defined anymore" unless defined?(Bundler::Fetcher)

module Bundler
  class Fetcher
    alias_method :orig_initialize, :initialize

    def initialize(remote_uri)
      new_uri = ::Bundler::Pgs::UriResolver.resolve(remote_uri)
      orig_initialize(new_uri)
    end
  end
end

##
# Replaces credential placeholder (e.g. http://_:_@....) with the credentials from the credentials file.
#
module Bundler::Pgs
  class UriResolver

    def self.resolve(uri)
      if uri_with_hidden_credentials?(uri)
        new_uri = uri_with_credentials(uri)
        Bundler.ui.debug "[bundler-pgs] uri with credentials: '#{new_uri}'"
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

        new_uri = nil
        if orig_uri.user == "_"
          credentials = yaml["default"]

          new_uri = orig_uri.dup
          new_uri.user     = credentials["user"].to_s.strip
          new_uri.password = credentials["password"].to_s.strip
        end

        new_uri
      end

      new_uri || orig_uri
    end

    def self.with_credential_file(&block)
      credential_filename = File.join(ENV["HOME"], ".gem", "gemserver_credentials")
      if File.exists?(credential_filename)
        yield(credential_filename) if block_given?
      end
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
