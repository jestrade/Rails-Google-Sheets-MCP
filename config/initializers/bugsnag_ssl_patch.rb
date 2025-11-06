require "openssl"

module Bugsnag
  class << self
    alias_method :original_notify, :notify

    def notify(*args, **kwargs, &block)
      # Temporarily disable CRL checking for this thread
      store = OpenSSL::X509::Store.new
      store.set_default_paths
      store.flags = OpenSSL::X509::V_FLAG_TRUSTED_FIRST
      OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:cert_store] = store
      original_notify(*args, **kwargs, &block)
    end
  end
end
