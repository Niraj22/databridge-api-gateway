module Api
  module V1
    class ProductsController < BaseController
      before_action :authorize_admin, only: [:create, :update, :destroy]
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
      rescue ServiceClient::ResourceNotFoundError => e
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
      rescue ServiceClient::ResourceNotFoundError => e
        render json: { error: 'Product not found' }, status: :not_found
      rescue ServiceClient::ServiceError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
      
      def destroy
        client = ProductServiceClient.new
        client.delete_product(params[:id])
        head :no_content
      rescue ServiceClient::ResourceNotFoundError => e
        render json: { error: 'Product not found' }, status: :not_found
      rescue ServiceClient::ServiceError => e
        render json: { error: e.message }, status: :internal_server_error
      end
      
      private
      
      def product_params
        params.permit(:name, :description, :sku, :price, :active)
      end
      
      def filter_params
        params.permit(:page, :per_page, :category_id, :price_min, :price_max, :sort_by, :sort_direction, :include_inactive)
      end
      
      def authorize_admin
        unless current_user && (current_user['role'].include?('admin') || current_user['role'].include?('product_manager'))
          render json: { error: 'Unauthorized' }, status: :forbidden
        end
      end
    end
  end
end