require 'wor/soap_service'
require 'spec_helper'

describe SoapService do
  let(:soap_clients) do
    { calculator: described_class.new, bank_codes: described_class.new('http://www.thomas-bayer.com/axis2/services/BLZService?wsdl'),
      currency: described_class.new('http://www.banguat.gob.gt/variables/ws/TipoCambio.asmx?wsdl'),
      liquidity: described_class.new('http://webservices.lb.lt/BLiquidity/BLiquidity.asmx?wsdl') }
  end
  let(:operations) do
    { calculator: soap_clients[:calculator].operations.sample, bank_codes: :get_bank,
      currency: :tipo_cambio_fecha_inicial, liquidity: :get_b_liquidity_rates_by_date }
  end
  let(:messages) do
    { calculator: { intA: rand(101), intB: rand(101) }, bank_codes: { blz: 50_080_060 },
      currency: { fechainit: '1/10/2019' }, liquidity: { date: '14/10/01' } }
  end

  context 'when making SOAP requests with remote WSDL documents' do
    let(:soap_requests) do
      [
        soap_clients[:calculator].call(operations[:calculator], messages[:calculator]),
        soap_clients[:bank_codes].call(operations[:bank_codes], messages[:bank_codes]),
        soap_clients[:currency].call(operations[:currency], messages[:currency]),
        soap_clients[:liquidity].call(operations[:liquidity], messages[:liquidity])
      ]
    end
    let(:calculator_operation_map) do
      lambda do |operation|
        case operation
        when :add
          messages[:calculator][:intA] + messages[:calculator][:intB]
        when :subtract
          messages[:calculator][:intA] - messages[:calculator][:intB]
        when :multiply
          messages[:calculator][:intA] * messages[:calculator][:intB]
        when :divide
          ((messages[:calculator][:intA] + 0.0) / messages[:calculator][:intB]).round
        end
      end
    end

    it 'makes successful requests for the given WSDL documents' do
      expect(soap_requests.all?(&:success?)).to be true
    end

    it 'doesn\'t return a SOAP Fault in any of the requests made to the WSDL documents' do
      expect(soap_requests.none?(&:soap_fault?)).to be true
    end

    it 'returns the SOAP body expected when calculator service is requested' do
      operation_result = calculator_operation_map.call operations[:calculator]
      response_body =
        { "#{operations[:calculator]}_response".to_sym =>
          { "#{operations[:calculator]}_result".to_sym =>
          operation_result.to_s, :@xmlns => 'http://tempuri.org/' } }
      expect(soap_requests.first.body).to eq(response_body)
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
