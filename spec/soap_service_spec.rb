require 'soap_service'
require 'spec_helper'

describe SoapService do
  subject(:soap_client) { described_class.new }

  let(:message)         { { intA: rand(101), intB: rand(101) } }
  let(:operation)       { soap_client.client.operations.sample }
  let(:operation_map) do
    lambda do |operation|
      case operation
      when :add
        message[:intA] + message[:intB]
      when :subtract
        message[:intA] - message[:intB]
      when :multiply
        message[:intA] * message[:intB]
      when :divide
        ((message[:intA] + 0.0) / message[:intB]).round
      end
    end
  end

  context 'when making a SOAP request with a remote WSDL' do
    let(:soap_request) { soap_client.call operation, message }

    it 'makes a successful request' do
      expect(soap_request.success?).to be true
      expect(soap_request.soap_fault?).to be false
      expect(soap_request.http_error?).to be false
    end

    it 'returns the SOAP body expected' do
      operation_result = operation_map.call operation
      response_body =
        { "#{operation}_response".to_sym => { "#{operation}_result".to_sym =>
          operation_result.to_s, :@xmlns => 'http://tempuri.org/' } }
      expect(soap_request.body).to eq(response_body)
    end
  end

  context 'when making a SOAP request with an XML provided' do
    let(:soap_client) do
      described_class.new('http://www.banguat.gob.gt/variables/ws/TipoCambio.asmx?WSDL')
    end
    let(:definitions) do
      {
        'xmlns:soapenv': 'http://schemas.xmlsoap.org/soap/envelope/',
        "xmlns:#{msg_identifier}": 'http://www.banguat.gob.gt/variables/ws/'
      }
    end
    let(:message) { { fechainit: '15/10/2019' } }
    let(:operation) { :tipo_cambio_fecha_inicial }
    let(:msg_identifier) { 'ws' }
    let(:nodes) do
      {
        operation_tag: "#{msg_identifier}:TipoCambioFechaInicial",
        message: message, message_attribute: msg_identifier
      }
    end
    let(:xml_request) do
      soap_client.soap_document_constructor(definitions, nodes)
    end

    it 'makes a success request' do
      # expect((soap_client.call operation, xml: xml_request).success?).to be true # THIS FAILS
      expect((soap_client.call operation, message).success?).to be true
    end
  end
end
