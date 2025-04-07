# app/controllers/api/v1/customers_controller.rb
module Api
  module V1
    class CustomersController < BaseController
      def index
        client = CustomerServiceClient.new
        customers = client.get_customers(filter_params)
        render json: customers
      rescue ServiceClient::ServiceError => e
        render json: { error: e.message }, status: :internal_server_error
      end
      
      def show
        client = CustomerServiceClient.new
        customer = client.get_user(params[:id])
        render json: customer
      rescue ServiceClient::ResourceNotFoundError
        render json: { error: 'Customer not found' }, status: :not_found
      rescue ServiceClient::ServiceError => e
        render json: { error: e.message }, status: :internal_server_error
      end
      
      def create
        client = CustomerServiceClient.new
        customer = client.create_user(customer_params)
        render json: customer, status: :created
      rescue ServiceClient::ServiceError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
      
      def update
        client = CustomerServiceClient.new
        customer = client.update_user(params[:id], customer_params)
        render json: customer
      rescue ServiceClient::ResourceNotFoundError
        render json: { error: 'Customer not found' }, status: :not_found
      rescue ServiceClient::ServiceError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
      
      def destroy
        client = CustomerServiceClient.new
        client.delete_user(params[:id])
        head :no_content
      rescue ServiceClient::ResourceNotFoundError
        render json: { error: 'Customer not found' }, status: :not_found
      rescue ServiceClient::ServiceError => e
        render json: { error: e.message }, status: :internal_server_error
      end
      
      private
      
      def customer_params
        params.permit(:name, :email, :password, :role)
      end
      
      def filter_params
        params.permit(:page, :per_page, :sort_by, :sort_direction)
      end
    end
  end
end
