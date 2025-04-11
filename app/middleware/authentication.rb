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
    begin
      # Decode the JWT token using the shared JWT helper
      decoded_token = DataBridgeShared::Auth::JwtHelper.decode(token, JwtConfig.secret_key)
      
      # The JWT.decode method returns an array with [payload, header]
      # We only need the payload (first element)
      payload = decoded_token.first
      
      # Perform additional validations if needed
      if Time.now.to_i > payload['exp'].to_i
        Rails.logger.warn "Token expired"
        return nil
      end
      
      # You could add more custom validations here:
      # - Check if the user exists in the database (though this would make it stateful)
      # - Verify specific claims like issuer (iss) or audience (aud)
      # - Check if the token is in a blocklist
      
      return payload
    rescue JWT::DecodeError => e
      # This catches various JWT-specific errors like:
      # - Invalid signature
      # - Claim validation failures
      # - Malformed tokens
      Rails.logger.warn "JWT decode error: #{e.message}"
      return nil
    rescue StandardError => e
      # Catch any other unexpected errors
      Rails.logger.error "Unexpected error decoding token: #{e.message}"
      return nil
    end
  end
end
