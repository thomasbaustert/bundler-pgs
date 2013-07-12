module BundlerPatch
  module CredentialFile

    def with_credential_file(&block)
      credential_filename = File.join(ENV["HOME"], ".gem", "gemserver_credentials")
      if File.exists?(credential_filename)
        yield(credential_filename) if block_given?
      end
    end
  end

end
