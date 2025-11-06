module Ai
  class ProductsController < ActionController::API
    def check
      product = product_params.to_h
      result = Products::CheckService.new(product: product).call

      if result[:success]
        render json: { message: result[:message] }, status: result[:status]
      else
        render json: { error: result[:error] }, status: result[:status]
      end
    end

    private

    def product_params
      params.require(:product).permit(:sku, :name, :price, :metadata)
    end
  end
end
