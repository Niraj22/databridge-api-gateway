module Api
    module V1
      class PaymentsController < BaseController
        def index
          client = OrderServiceClient.new
          payments = client.get_payments(params[:order_id])
          render json: payments
        rescue ServiceClient::ResourceNotFoundError
          render json: { error: 'Order not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :internal_server_error
        end
        
        def create
          client = OrderServiceClient.new
          payment = client.create_payment(params[:order_id], payment_params)
          render json: payment, status: :created
        rescue ServiceClient::ResourceNotFoundError
          render json: { error: 'Order not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
        
        private
        
        def payment_params
          params.permit(:amount, :payment_method, :status, :transaction_id)
        end
      end
    end
  end