require "net/http"
require 'net/http/persistent'

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

