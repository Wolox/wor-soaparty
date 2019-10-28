require 'soap_service'
require 'spec_helper'

describe SoapService do
  let(:soap_clients) do
    { calculator: described_class.new, bank_codes: described_class.new('http://www.thomas-bayer.com/axis2/services/BLZService?wsdl'),
      currency: described_class.new('http://www.banguat.gob.gt/variables/ws/TipoCambio.asmx?WSDL')
    }
  end
  let(:operations) do
    { calculator: soap_clients[:calculator].client.operations.sample, bank_codes: :get_bank,
      currency: :tipo_cambio_fecha_inicial }
  end
  let(:messages) do
    { calculator: { intA: rand(101), intB: rand(101) }, bank_codes: { blz: 50_080_060 },
      currency: { fechainit: '1/10/2019' } }
  end

  context 'when making SOAP requests with remote WSDL documents' do
    let(:calculator_soap_request) do
      soap_clients[:calculator].call(operations[:calculator], messages[:calculator])
    end
    let(:bank_codes_soap_request) do
      soap_clients[:bank_codes].call(operations[:bank_codes], messages[:bank_codes])
    end
    let(:currency_soap_request) do
      soap_clients[:currency].call(operations[:currency], messages[:currency])
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
      expect(calculator_soap_request.success?).to be true
      expect(calculator_soap_request.soap_fault?).to be false
      expect(bank_codes_soap_request.success?).to be true
      expect(bank_codes_soap_request.soap_fault?).to be false
      expect(currency_soap_request.success?).to be true
      expect(currency_soap_request.soap_fault?).to be false
    end

    it 'returns the SOAP body expected when calculator service is requested' do
      operation_result = calculator_operation_map.call operations[:calculator]
      response_body =
        { "#{operations[:calculator]}_response".to_sym =>
          { "#{operations[:calculator]}_result".to_sym =>
          operation_result.to_s, :@xmlns => 'http://tempuri.org/' } }
      byebug
      expect(calculator_soap_request.body).to eq(response_body)
    end
  end
end
