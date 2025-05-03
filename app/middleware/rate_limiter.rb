class RateLimiter
  def initialize(app, options = {})
    @app = app
    @limit = options[:limit] || 100
    @period = options[:period] || 60  # in seconds
    @redis = Redis.new(url: ENV.fetch('REDIS_URL'))
  end
  
  def call(env)
    request = ActionDispatch::Request.new(env)
    
    # Skip rate limiting for certain paths
    return @app.call(env) if skip_rate_limiting?(request)
    
    client_id = identify_client(request)
    
    if rate_limited?(client_id)
      rate_limit_exceeded_response
    else
      status, headers, response = @app.call(env)
      
      # Add rate limit headers
      add_rate_limit_headers(headers, client_id)
      
      [status, headers, response]
    end
  end
  
  private
  
  def skip_rate_limiting?(request)
    # Skip health checks or other paths
    request.path == '/' || request.path.start_with?('/api-docs')
  end
  
  def identify_client(request)
    # Extract from JWT token, or fallback to IP
    token = extract_token(request)
    if token
      begin
        payload = DataBridgeShared::Auth::JwtHelper.decode(token, jwt_secret)
        return "user:#{payload&.first['user_id']}" if payload && payload&.first['user_id']
      rescue => e
        # Token invalid, fall back to IP
        Rails.logger.debug "Invalid token for rate limiting: #{e.message}" if defined?(Rails.logger)
      end
    end
    
    # Fallback to IP address
    "ip:#{request.ip}"
  end
  
  def extract_token(request)
    header = request.headers['Authorization']
    header&.split(' ')&.last
  end
  
  def jwt_secret
    Rails.application.credentials.jwt_secret_key
  end
  
  def rate_limited?(client_id)
    current_count = increment_counter(client_id)
    current_count > @limit
  end
  
  def increment_counter(client_id)
    key = "rate_limit:#{client_id}"
    
    # If key doesn't exist, set it with expiry
    count = @redis.get(key)
    if count.nil?
      @redis.setex(key, @period, 1)
      return 1
    end
    
    # Increment the counter
    @redis.incr(key).to_i
  end
  
  def remaining_requests(client_id)
    key = "rate_limit:#{client_id}"
    count = @redis.get(key).to_i
    [@limit - count, 0].max
  end
  
  def next_reset_time(client_id)
    key = "rate_limit:#{client_id}"
    ttl = @redis.ttl(key)
    Time.now.to_i + (ttl > 0 ? ttl : @period)
  end
  
  def add_rate_limit_headers(headers, client_id)
    headers['X-RateLimit-Limit'] = @limit.to_s
    headers['X-RateLimit-Remaining'] = remaining_requests(client_id).to_s
    headers['X-RateLimit-Reset'] = next_reset_time(client_id).to_s
  end
  
  def rate_limit_exceeded_response
    [
      429,
      {
        'Content-Type' => 'application/json',
        'X-RateLimit-Limit' => @limit.to_s,
        'X-RateLimit-Remaining' => '0',
        'X-RateLimit-Reset' => next_reset_time('temp').to_s,
        'Retry-After' => @period.to_s
      },
      [{ error: 'Rate limit exceeded. Please try again later.' }.to_json]
    ]
  end
end