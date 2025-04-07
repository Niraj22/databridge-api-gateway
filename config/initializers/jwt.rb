require 'jwt'

module JwtConfig
  class << self
    def secret_key
      Rails.application.credentials.fetch(:jwt_secret_key)
    end
    
    def algorithm
      'HS256'
    end
    
    def token_expiry
      24.hours.to_i
    end
  end
end
