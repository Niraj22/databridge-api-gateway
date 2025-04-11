module Api
    module V1
      class OrdersController < BaseController
        def index
          client = OrderServiceClient.new
          orders = client.get_orders(filter_params)
          render json: orders
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :internal_server_error
        end
        
        def show
          client = OrderServiceClient.new
          order = client.get_order(params[:id])
          render json: order
        rescue ServiceClient::ResourceNotFoundError
          render json: { error: 'Order not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :internal_server_error
        end
        
        def create
          client = OrderServiceClient.new
          enhanced_params = order_params.merge(customer_id: current_user["user_id"])
          order = client.create_order(enhanced_params)
          render json: order, status: :created
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
        
        def update
          client = OrderServiceClient.new
          order = client.update_order(params[:id], order_params)
          render json: order
        rescue ServiceClient::ResourceNotFoundError
          render json: { error: 'Order not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
        
        def destroy
          client = OrderServiceClient.new
          client.delete_order(params[:id])
          head :no_content
        rescue ServiceClient::ResourceNotFoundError
          render json: { error: 'Order not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :internal_server_error
        end
        
        private
        
        def order_params
          {
            status: 'created',
            total_amount: calculate_total_amount,
            line_items: params[:line_items]
          }
        end
        
        def calculate_total_amount
          # Calculate from line_items if not explicitly provided
          return params[:total_amount] if params[:total_amount].present?
          
          params[:line_items]&.sum { |item| item[:quantity].to_i * item[:unit_price].to_f } || 0
        end
        
        def filter_params
          params.permit(:page, :per_page, :status, :customer_id, :start_date, :end_date, :sort_by, :sort_direction)
        end
      end
    end
  end