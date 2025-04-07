# app/middleware/rate_limiting.rb
class RateLimiting
  DEFAULT_LIMIT = 100    
  DEFAULT_PERIOD = 3600   
  
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    
    # Skip rate limiting for certain paths like health checks
    return @app.call(env) if skip_rate_limiting?(request)

    # Get client identifier (IP address or user ID if authenticated)
    client_id = client_identifier(request)
    
    # Check if client has exceeded rate limit
    if rate_limit_exceeded?(client_id)
      # Return 429 Too Many Requests
      return rate_limit_exceeded_response
    end
    
    # Increment request count for this client
    increment_request_count(client_id)
    
    # Add rate limit headers to the response
    status, headers, response = @app.call(env)
    add_rate_limit_headers(headers, client_id)
    
    [status, headers, response]
  end

  private

  def skip_rate_limiting?(request)
    # Skip rate limiting for health checks or specific paths
    request.path == '/' || request.path == '/health'
  end

  def client_identifier(request)
    # If user is authenticated, use user_id as identifier
    if request.env['current_user'] && request.env['current_user']['user_id']
      "user:#{request.env['current_user']['user_id']}"
    else
      # Otherwise use IP address
      "ip:#{request.ip}"
    end
  end

  def rate_limit_exceeded?(client_id)
    current_count = get_request_count(client_id)
    limit = get_rate_limit(client_id)
    
    current_count >= limit
  end

  def get_request_count(client_id)
    # In a real implementation, this would use Redis
    # For now, we'll use a simple in-memory store
    store[client_id] || 0
  end

  def increment_request_count(client_id)
    # Get current count
    current_count = get_request_count(client_id)
    
    # Increment count
    store[client_id] = current_count + 1
    
    # Set expiration if this is the first request
    if current_count == 0
      # In a real implementation, this would set Redis key expiration
      # For now, we'll use a simple in-memory approach with a cleanup task
      expiration_timestamps[client_id] = Time.now.to_i + get_rate_limit_period(client_id)
    end
    
    # Cleanup expired entries (would be handled by Redis TTL in production)
    cleanup_expired_entries if rand < 0.01 # 1% chance to run cleanup on each request
  end

  def cleanup_expired_entries
    current_time = Time.now.to_i
    expiration_timestamps.each do |client_id, expiry|
      if current_time > expiry
        store.delete(client_id)
        expiration_timestamps.delete(client_id)
      end
    end
  end

  def get_rate_limit(client_id)
    # Could have different limits for different users/IPs
    # For now, return default limit
    DEFAULT_LIMIT
  end

  def get_rate_limit_period(client_id)
    # Could have different periods for different users/IPs
    # For now, return default period
    DEFAULT_PERIOD
  end

  def add_rate_limit_headers(headers, client_id)
    current_count = get_request_count(client_id)
    limit = get_rate_limit(client_id)
    
    headers['X-RateLimit-Limit'] = limit.to_s
    headers['X-RateLimit-Remaining'] = [0, limit - current_count].max.to_s
    
    # Add reset timestamp if we have it
    if expiration_timestamps[client_id]
      headers['X-RateLimit-Reset'] = expiration_timestamps[client_id].to_s
    end
  end

  def rate_limit_exceeded_response
    [
      429,
      { 'Content-Type' => 'application/json' },
      [{ error: 'Rate limit exceeded. Please try again later.' }.to_json]
    ]
  end

  def store
    @@store ||= {}
  end

  def expiration_timestamps
    @@expiration_timestamps ||= {}
  end
end
