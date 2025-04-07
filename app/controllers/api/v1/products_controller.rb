module Api
  module V1
    class ProductsController < BaseController
      # Allow public access to index and show actions
      skip_before_action :authenticate_request, only: [:index, :show]
      
      def index
        client = ProductServiceClient.new
        products = client.get_products(filter_params)
        render json: products
      rescue ServiceClient::ServiceError => e
        render json: { error: e.message }, status: :internal_server_error
      end
      
      def show
        client = ProductServiceClient.new
        product = client.get_product(params[:id])
        render json: product
      rescue ServiceClient::ResourceNotFoundError
        render json: { error: 'Product not found' }, status: :not_found
      rescue ServiceClient::ServiceError => e
        render json: { error: e.message }, status: :internal_server_error
      end
      
      def create
        client = ProductServiceClient.new
        product = client.create_product(product_params)
        render json: product, status: :created
      rescue ServiceClient::ServiceError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
      
      def update
        client = ProductServiceClient.new
        product = client.update_product(params[:id], product_params)
        render json: product
      rescue ServiceClient::ResourceNotFoundError
        render json: { error: 'Product not found' }, status: :not_found
      rescue ServiceClient::ServiceError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
      
      def destroy
        client = ProductServiceClient.new
        client.delete_product(params[:id])
        head :no_content
      rescue ServiceClient::ResourceNotFoundError
        render json: { error: 'Product not found' }, status: :not_found
      rescue ServiceClient::ServiceError => e
        render json: { error: e.message }, status: :internal_server_error
      end
      
      private
      
      def product_params
        params.permit(:name, :description, :price, :category_id, :inventory_count, :active)
      end
      
      def filter_params
        params.permit(:page, :per_page, :category, :sort_by, :sort_direction, :min_price, :max_price)
      end
    end
  end
end
