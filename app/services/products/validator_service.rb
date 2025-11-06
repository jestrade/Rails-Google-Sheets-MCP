module Products
  class ValidatorService
    attr_reader :errors

    def initialize(product)
      @product = product
      @errors = []
    end

    def valid?
      validate_sku
      @errors.empty?
    end

    def error_message
      @errors.join(", ")
    end

    private

    def validate_sku
      if @product["sku"].blank?
        @errors << "sku is required"
      end
    end
  end
end
