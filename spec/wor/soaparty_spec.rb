require 'soap_service'
require 'spec_helper'

describe SoapService do
  subject(:soap_client) { described_class.new }
  let(:message)         { { intA: rand(101), intB: rand(101) } }
  let(:operation)       { soap_client.client.operations.sample }
  let(:operation_map) do
    lambda do |operation|
      case operation.to_s
      when 'add'
        message[:intA] + message[:intB]
      when 'subtract'
        message[:intA] - message[:intB]
      when 'multiply'
        message[:intA] * message[:intB]
      when 'divide'
        ((message[:intA] + 0.0) / message[:intB]).round
      end
    end
  end

  context 'When making a SOAP request with a remote WSDL' do

    it 'Makes a successful request' do
      operation_result = operation_map.call operation
      response_body =
        { "#{operation}_response".to_sym => { "#{operation}_result".to_sym =>
          operation_result.to_s, :@xmlns => 'http://tempuri.org/' } }

      expect((soap_client.call operation, message).body).to eq(response_body)
    end
  end
end
