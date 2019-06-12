require 'savon'

class SoapService
  attr_accessor :client

  def initialize(wsdl = 'http://www.dneonline.com/calculator.asmx?wsdl')
    @client = Savon.client(wsdl: wsdl)
  end

  def call(operation, message)
    @client.call(operation, message: message)
  end
end
