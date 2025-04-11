module Api
  module V1
    class AuthController < Api::BaseController
      skip_before_action :authenticate_request, only: [:login, :register]
      
      def login
        client = CustomerServiceClient.new
        
        begin
          user_data = client.authenticate(params[:email], params[:password])
          token = generate_token(user_data)
          
          render json: { token: token, user: user_data }
        rescue ServiceClient::UnauthorizedError
          render json: { error: 'Invalid credentials' }, status: :unauthorized
        end
      end
      
      def register
        client = CustomerServiceClient.new
        
        begin
          user = client.register(user_params)
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
        user = user['user'] || user
        payload = {
          user_id: user['id'],
          email: user['email'],
          role: user['role'],
          exp: Time.now.to_i + JwtConfig.token_expiry
        }
        
        DataBridgeShared::Auth::JwtHelper.encode(payload, JwtConfig.secret_key)
      end

      def user_params
        params.require(:auth).permit(:email, :password, :name, :role)
      end
    end
  end
end