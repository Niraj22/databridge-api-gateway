module Api
    module V1
      class AddressesController < BaseController
        def index
          client = CustomerServiceClient.new                   
          addresses = client.get_addresses(params[:customer_id])
          render json: addresses
        rescue ServiceClient::ResourceNotFoundError
          render json: { error: 'Customer not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :internal_server_error
        end
        
        def show
          client = CustomerServiceClient.new
          address = client.get_address(params[:customer_id], params[:id])
          render json: address
        rescue ServiceClient::ResourceNotFoundError
          render json: { error: 'Address not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :internal_server_error
        end
        
        def create
          client = CustomerServiceClient.new
          address = client.create_address(params[:customer_id], address_params)
          render json: address, status: :created
        rescue ServiceClient::ResourceNotFoundError
          render json: { error: 'Customer not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
        
        def update
          client = CustomerServiceClient.new
          address = client.update_address(params[:customer_id], params[:id], address_params)
          render json: address
        rescue ServiceClient::ResourceNotFoundError
          render json: { error: 'Address not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
        
        def destroy
          client = CustomerServiceClient.new
          client.delete_address(params[:customer_id], params[:id])
          head :no_content
        rescue ServiceClient::ResourceNotFoundError
          render json: { error: 'Address not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :internal_server_error
        end
        
        private
        
        def address_params
          params.permit(:address_type, :street, :city, :state, :postal_code, :country, :is_default)
        end
      end
    end
  end