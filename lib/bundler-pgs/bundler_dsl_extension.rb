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

