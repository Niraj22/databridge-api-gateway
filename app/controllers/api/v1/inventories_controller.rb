# app/controllers/api/v1/inventories_controller.rb
module Api
    module V1
      class InventoriesController < BaseController
        before_action :authorize_admin
        
        def show
          client = ProductServiceClient.new
          inventory = client.get_product_inventory(params[:product_id])
          render json: inventory
        rescue ServiceClient::ResourceNotFoundError => e
          render json: { error: 'Product not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :internal_server_error
        end
        
        def update
          client = ProductServiceClient.new
          inventory = client.update_product_inventory(params[:product_id], inventory_params)
          render json: inventory
        rescue ServiceClient::ResourceNotFoundError => e
          render json: { error: 'Product not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
        
        def batch_update
          client = ProductServiceClient.new
          result = client.batch_update_inventory(batch_params)
          render json: result
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
        
        private
        
        def inventory_params
          params.permit(:quantity, :low_stock_threshold)
        end
        
        def batch_params
          params.permit(inventories: [:product_id, :quantity])
        end
        
        def authorize_admin
          unless current_user && (current_user['role'].include?('admin') || current_user['role'].include?('product_manager'))
            render json: { error: 'Unauthorized' }, status: :forbidden
          end
        end
      end
    end
  end