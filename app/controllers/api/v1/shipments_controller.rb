module Api
    module V1
      class ShipmentsController < BaseController
        def index
          client = OrderServiceClient.new
          shipments = client.get_shipments(params[:order_id])
          render json: shipments
        rescue ServiceClient::ResourceNotFoundError
          render json: { error: 'Order not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :internal_server_error
        end
        
        def create
          client = OrderServiceClient.new
          shipment = client.create_shipment(params[:order_id], shipment_params)
          render json: shipment, status: :created
        rescue ServiceClient::ResourceNotFoundError
          render json: { error: 'Order not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
        
        def update
          client = OrderServiceClient.new
          shipment = client.update_shipment(params[:order_id], params[:id], shipment_params)
          render json: shipment
        rescue ServiceClient::ResourceNotFoundError
          render json: { error: 'Shipment not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
        
        private
        
        def shipment_params
          params.permit(:tracking_number, :carrier, :status)
        end
      end
    end
  end