require 'wor/soaparty/version'
require 'savon'

module Wor
  module Soaparty
    def init_client(wsdl)
      Savon.client wsdl: wsdl
    end
  end
end
