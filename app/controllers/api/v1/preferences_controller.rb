module Api
    module V1
      class PreferencesController < BaseController
        def index
          client = CustomerServiceClient.new
          preferences = client.get_preferences(params[:customer_id])
          render json: preferences
        rescue ServiceClient::ResourceNotFoundError
          render json: { error: 'Customer not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :internal_server_error
        end
        
        def show
          client = CustomerServiceClient.new
          preference = client.get_preference(params[:customer_id], params[:id])
          render json: preference
        rescue ServiceClient::ResourceNotFoundError
          render json: { error: 'Preference not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :internal_server_error
        end
        
        def update
          client = CustomerServiceClient.new
          preference = client.update_preference(params[:customer_id], params[:id], params[:value])
          render json: preference
        rescue ServiceClient::ResourceNotFoundError
          render json: { error: 'Customer not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
        
        def destroy
          client = CustomerServiceClient.new
          client.delete_preference(params[:customer_id], params[:id])
          head :no_content
        rescue ServiceClient::ResourceNotFoundError
          render json: { error: 'Preference not found' }, status: :not_found
        rescue ServiceClient::ServiceError => e
          render json: { error: e.message }, status: :internal_server_error
        end
      end
    end
  end