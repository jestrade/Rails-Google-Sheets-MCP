require 'rails_helper'

RSpec.describe "Ai::ProductsController", type: :request do
  describe "POST /ai/products/check" do
    let(:product_params) do
      {
        product: {
          sku: 'ABC-123',
          name: 'Test Product',
          price: '19.99',
          metadata: 'test data'
        }
      }
    end

    context 'when product check is successful' do
      let(:check_service) { instance_double(Products::CheckService) }
      let(:success_result) do
        {
          success: true,
          message: 'Product successfully added!',
          status: :ok
        }
      end

      before do
        allow(Products::CheckService).to receive(:new).and_return(check_service)
        allow(check_service).to receive(:call).and_return(success_result)
      end

      it 'returns success response' do
        post '/ai/products/check', params: product_params, as: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({
          'message' => 'Product successfully added!'
        })
      end

      it 'calls CheckService with product hash' do
        expect(Products::CheckService).to receive(:new).with(
          product: hash_including(
            'sku' => 'ABC-123',
            'name' => 'Test Product',
            'price' => '19.99',
            'metadata' => 'test data'
          )
        )

        post '/ai/products/check', params: product_params, as: :json
      end
    end

    context 'when product already exists' do
      let(:check_service) { instance_double(Products::CheckService) }
      let(:exists_result) do
        {
          success: true,
          message: 'Product with SKU ABC-123 already exists.',
          status: :ok
        }
      end

      before do
        allow(Products::CheckService).to receive(:new).and_return(check_service)
        allow(check_service).to receive(:call).and_return(exists_result)
      end

      it 'returns existing product message' do
        post '/ai/products/check', params: product_params, as: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({
          'message' => 'Product with SKU ABC-123 already exists.'
        })
      end
    end

    context 'when validation fails' do
      let(:check_service) { instance_double(Products::CheckService) }
      let(:error_result) do
        {
          success: false,
          error: 'sku is required',
          status: :bad_request
        }
      end

      before do
        allow(Products::CheckService).to receive(:new).and_return(check_service)
        allow(check_service).to receive(:call).and_return(error_result)
      end

      it 'returns error response' do
        post '/ai/products/check', params: { product: { name: 'Test' } }, as: :json

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to eq({
          'error' => 'sku is required'
        })
      end
    end

    context 'when internal error occurs' do
      let(:check_service) { instance_double(Products::CheckService) }
      let(:error_result) do
        {
          success: false,
          error: 'Database connection failed',
          status: :internal_server_error
        }
      end

      before do
        allow(Products::CheckService).to receive(:new).and_return(check_service)
        allow(check_service).to receive(:call).and_return(error_result)
      end

      it 'returns internal server error' do
        post '/ai/products/check', params: product_params, as: :json

        expect(response).to have_http_status(:internal_server_error)
        expect(JSON.parse(response.body)).to eq({
          'error' => 'Database connection failed'
        })
      end
    end

    context 'when product param is missing' do
      it 'returns parameter missing error' do
        post '/ai/products/check', params: {}, as: :json

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json).to have_key('error')
      end
    end

    context 'with unpermitted parameters' do
      let(:check_service) { instance_double(Products::CheckService) }
      let(:success_result) do
        {
          success: true,
          message: 'Product added!',
          status: :ok
        }
      end

      before do
        allow(Products::CheckService).to receive(:new).and_return(check_service)
        allow(check_service).to receive(:call).and_return(success_result)
      end

      it 'filters out unpermitted parameters' do
        params_with_extra = product_params.deep_merge(
          product: { admin: true, unauthorized: 'value' }
        )

        expect(Products::CheckService).to receive(:new) do |args|
          product_hash = args[:product]
          expect(product_hash).not_to have_key('admin')
          expect(product_hash).not_to have_key('unauthorized')
          check_service
        end

        post '/ai/products/check', params: params_with_extra, as: :json
      end
    end
  end
end
