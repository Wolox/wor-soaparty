class SoapService
  include Wor::Soaparty
  attr_accessor :client

  MAIN_SOAP_NODES = {
    root: 'soapenv:Envelope', header: 'soapenv:Header', body: 'soapenv:Body'
  }.freeze

  def initialize(wsdl = 'http://www.dneonline.com/calculator.asmx?wsdl')
    @client = init_client(wsdl)
  end

  def call(operation, message)
    @client.call(operation, message: message)
  end

  def operations
    @client.operations
  end

  def soap_document_constructor(definitions, nodes)
    Nokogiri::XML::Builder.new do |xml|
      document_nodes_generator(xml, definitions, nodes)
    end.to_xml.squish
  end

  private

  def document_nodes_generator(xml_object, definitions, nodes)
    xml_object.send(MAIN_SOAP_NODES[:root], definitions) do
      xml_object.send(MAIN_SOAP_NODES[:header])
      xml_object.send(MAIN_SOAP_NODES[:body]) do
        xml_object.send(nodes[:operation_tag]) do
          message_nodes_constructor(nodes[:message],
                                    nodes[:message_attribute], xml_object)
        end
      end
    end
  end

  def message_nodes_constructor(message_hash, message_identifier, xml_object)
    message_nodes = message_hash.map do |key, val|
      { "#{message_identifier}:#{key}": val }
    end
    message_nodes.each { |n| xml_object.send(n.keys.first, n.values.first) }
  end
end
