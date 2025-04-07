# app/middleware/authentication.rb
class Authentication
  def initialize(app)
    @app = app
  end
  
  def call(env)
    token = extract_token(env)
    
    if token
      begin
        payload = decode_token(token)
        env['current_user'] = payload
      rescue StandardError => e
        # Invalid token, but we'll continue processing
        Rails.logger.warn "Invalid token: #{e.message}"
      end
    end
    
    @app.call(env)
  end
  
  private
  
  def extract_token(env)
    request = ActionDispatch::Request.new(env)
    authorization = request.headers['Authorization']
    
    return nil unless authorization
    
    authorization.split(' ').last
  end
  
  def decode_token(token)
    # Use JWT to decode the token
    # In a real app, you would use the JwtConfig or DataBridgeShared::Auth::JwtHelper
    
    # For now, just return a dummy payload to allow the app to boot
    { 'user_id' => '123', 'email' => 'test@example.com', 'roles' => ['user'] }
  end
end
