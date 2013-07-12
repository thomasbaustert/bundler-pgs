##
# Patches bundler to use url with the credentials.
#
module Bundler
  class RubygemsIntegration
    def download_gem(spec, uri, path)
      new_uri = ::BundlerPatch::UriResolver.resolve(uri)
      Gem::RemoteFetcher.fetcher.download(spec, new_uri, path)
    end
  end
end

##
# Replaces credential placeholder (e.g. http://_:_@....) with the credentials from the credentials file.
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
