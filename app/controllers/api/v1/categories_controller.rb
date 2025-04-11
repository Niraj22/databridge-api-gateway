# app/controllers/api/v1/categories_controller.rb
module Api
    module V1
      class CategoriesController < BaseController
        before_action :authorize_admin, only: [:create, :update, :destroy]
        
        def index
          client = ProductServiceClient.new
          categories = client.get_categories(filter_params)
          render json: categories
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :internal_server_error
        end
        
        def show
          client = ProductServiceClient.new
          category = client.get_category(params[:id])
          render json: category
        rescue ServiceClient::ResourceNotFoundError => e
          render json: { error: 'Category not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :internal_server_error
        end
        
        def create
          client = ProductServiceClient.new
          category = client.create_category(category_params)
          render json: category, status: :created
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
        
        def update
          client = ProductServiceClient.new
          category = client.update_category(params[:id], category_params)
          render json: category
        rescue ServiceClient::ResourceNotFoundError => e
          render json: { error: 'Category not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
        
        def destroy
          client = ProductServiceClient.new
          client.delete_category(params[:id])
          head :no_content
        rescue ServiceClient::ResourceNotFoundError => e
          render json: { error: 'Category not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :internal_server_error
        end
        
        private
        
        def category_params
          params.permit(:name, :description, :parent_id, :active)
        end
        
        def filter_params
          params.permit(:parent_id, :root, :include_inactive)
        end
        
        def authorize_admin
          unless current_user && (current_user['role'].include?('admin') || current_user['role'].include?('product_manager'))
            render json: { error: 'Unauthorized' }, status: :forbidden
          end
        end
      end
    end
  end