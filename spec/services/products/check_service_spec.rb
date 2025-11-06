require 'rails_helper'

RSpec.describe Products::CheckService do
  let(:product) do
    {
      'sku' => 'ABC-123',
      'name' => 'Test Product',
      'price' => '19.99',
      'metadata' => 'test metadata'
    }
  end
  let(:sheets_service) { instance_double(GoogleSheetsService) }
  let(:gemini_service) { instance_double(GeminiService) }
  let(:service) do
    described_class.new(
      product: product,
      sheets_service: sheets_service,
      gemini_service: gemini_service
    )
  end

  describe '#call' do
    context 'when product validation fails' do
      let(:product) { { 'name' => 'Test Product' } }

      it 'returns error result' do
        result = service.call

        expect(result[:success]).to be false
        expect(result[:error]).to eq('sku is required')
        expect(result[:status]).to eq(:bad_request)
      end

      it 'does not call sheets service' do
        expect(sheets_service).not_to receive(:find_by_sku)
        service.call
      end
    end

    context 'when product already exists' do
      let(:existing_product) do
        { 'sku' => 'ABC-123', 'name' => 'Existing Product' }
      end

      before do
        allow(sheets_service).to receive(:find_by_sku).with('ABC-123').and_return(existing_product)
      end

      it 'returns success with existing product message' do
        result = service.call

        expect(result[:success]).to be true
        expect(result[:message]).to eq('Product with SKU ABC-123 already exists.')
        expect(result[:status]).to eq(:ok)
      end

      it 'does not add the product' do
        expect(sheets_service).not_to receive(:add_product)
        service.call
      end

      it 'does not call Gemini service' do
        expect(gemini_service).not_to receive(:generate_product_confirmation)
        service.call
      end
    end

    context 'when product does not exist' do
      let(:confirmation_message) { 'Product successfully added!' }

      before do
        allow(sheets_service).to receive(:find_by_sku).with('ABC-123').and_return(nil)
        allow(sheets_service).to receive(:add_product).with(product)
        allow(gemini_service).to receive(:generate_product_confirmation).with(product).and_return(confirmation_message)
      end

      it 'generates confirmation message' do
        expect(gemini_service).to receive(:generate_product_confirmation).with(product)
        service.call
      end

      it 'adds product to sheets' do
        expect(sheets_service).to receive(:add_product).with(product)
        service.call
      end

      it 'returns success with confirmation message' do
        result = service.call

        expect(result[:success]).to be true
        expect(result[:message]).to eq(confirmation_message)
        expect(result[:status]).to eq(:ok)
      end
    end

    context 'when an exception occurs' do
      before do
        allow(sheets_service).to receive(:find_by_sku).and_raise(StandardError.new('Database error'))
      end

      it 'notifies Bugsnag' do
        expect(Bugsnag).to receive(:notify).with(instance_of(StandardError))
        service.call
      end

      it 'returns error result' do
        allow(Bugsnag).to receive(:notify)
        result = service.call

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Database error')
        expect(result[:status]).to eq(:internal_server_error)
      end
    end
  end

  describe 'dependency injection' do
    it 'accepts custom sheets service' do
      custom_sheets_service = instance_double(GoogleSheetsService)
      service = described_class.new(product: product, sheets_service: custom_sheets_service)
      expect(service.instance_variable_get(:@sheets_service)).to eq(custom_sheets_service)
    end

    it 'accepts custom gemini service' do
      custom_gemini_service = instance_double(GeminiService)
      service = described_class.new(product: product, gemini_service: custom_gemini_service)
      expect(service.instance_variable_get(:@gemini_service)).to eq(custom_gemini_service)
    end
  end
end
