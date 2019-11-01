class SoapService
  include Wor::Soaparty
  attr_accessor :client

  def initialize(wsdl = 'http://www.dneonline.com/calculator.asmx?wsdl')
    @client = init_client(wsdl)
  end

  def call(operation, message)
    @client.call(operation, message: message)
  end

  def operations
    @client.operations
  end
end
