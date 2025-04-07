module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_request, only: [:login, :register]
      
      def login
        client = CustomerServiceClient.new
        
        begin
          user = client.authenticate(params[:email], params[:password])
          token = generate_token(user)
          
          event_publisher = DataBridgeShared::Clients::EventPublisher.new
          event_publisher.publish('user.login.success', { user_id: user['id'], timestamp: Time.now.iso8601 })
          
          render json: { token: token, user: user }
        rescue ServiceClient::UnauthorizedError
          event_publisher = DataBridgeShared::Clients::EventPublisher.new
          event_publisher.publish('user.login.failed', { email: params[:email], timestamp: Time.now.iso8601 })
          
          render json: { error: 'Invalid credentials' }, status: :unauthorized
        end
      end
      
      def register
        client = CustomerServiceClient.new
        
        begin
          user = client.create_user(user_params)
          token = generate_token(user)
          
          render json: { token: token, user: user }, status: :created
        rescue StandardError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end
      end
      
      def refresh
        render json: { token: generate_token(current_user) }
      end
      
      private
      
      def generate_token(user)
        payload = {
          user_id: user['id'],
          email: user['email'],
          roles: user['roles'],
          exp: Time.now.to_i + JwtConfig.token_expiry
        }
        
        DataBridgeShared::Auth::JwtHelper.encode(payload, JwtConfig.secret_key)
      end
      
      def user_params
        params.permit(:email, :password, :name, :role)
      end
    end
  end
end
