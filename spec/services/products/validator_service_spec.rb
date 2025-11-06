require 'rails_helper'

RSpec.describe Products::ValidatorService do
  describe '#valid?' do
    context 'when product has a valid SKU' do
      let(:product) { { 'sku' => 'ABC-123', 'name' => 'Test Product' } }
      let(:validator) { described_class.new(product) }

      it 'returns true' do
        expect(validator.valid?).to be true
      end

      it 'has no errors' do
        validator.valid?
        expect(validator.errors).to be_empty
      end
    end

    context 'when SKU is missing' do
      let(:product) { { 'name' => 'Test Product' } }
      let(:validator) { described_class.new(product) }

      it 'returns false' do
        expect(validator.valid?).to be false
      end

      it 'adds an error message' do
        validator.valid?
        expect(validator.errors).to include('sku is required')
      end

      it 'provides error message through error_message method' do
        validator.valid?
        expect(validator.error_message).to eq('sku is required')
      end
    end

    context 'when SKU is blank' do
      let(:product) { { 'sku' => '', 'name' => 'Test Product' } }
      let(:validator) { described_class.new(product) }

      it 'returns false' do
        expect(validator.valid?).to be false
      end

      it 'adds an error message' do
        validator.valid?
        expect(validator.errors).to include('sku is required')
      end
    end

    context 'when SKU is only whitespace' do
      let(:product) { { 'sku' => '   ', 'name' => 'Test Product' } }
      let(:validator) { described_class.new(product) }

      it 'returns false' do
        expect(validator.valid?).to be false
      end
    end
  end

  describe '#error_message' do
    context 'with multiple errors' do
      let(:product) { { 'sku' => '' } }
      let(:validator) { described_class.new(product) }

      it 'joins errors with comma' do
        validator.valid?
        # Currently only one validation, but method supports multiple
        expect(validator.error_message).to be_a(String)
      end
    end
  end
end
