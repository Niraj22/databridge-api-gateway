# spec/middleware/rate_limiter_spec.rb
require 'rails_helper'

RSpec.describe RateLimiter do
  let(:app) { ->(env) { [200, {}, ['OK']] } }
  let(:limit) { 5 }
  let(:middleware) { RateLimiter.new(app, limit: limit, period: 60) }
  let(:request) { Rack::MockRequest.new(middleware) }
  
  # Mock JWT helper
  before do
    allow(DataBridgeShared::Auth::JwtHelper).to receive(:decode).and_return([{'user_id' => 1}])
    allow_any_instance_of(RateLimiter).to receive(:jwt_secret).and_return('test_secret')
    
    # Clear Redis before each test
    redis = Redis.new(url: ENV.fetch('REDIS_URL'))
    redis.flushdb
  end
  
  describe 'rate limiting' do
    it 'allows requests under the limit' do
      3.times do
        response = request.get('/api/v1/products')
        expect(response.status).to eq(200)
      end
    end
    
    it 'blocks requests over the limit' do
      limit.times do
        request.get('/api/v1/products')
      end
      
      response = request.get('/api/v1/products')
      expect(response.status).to eq(429)
      expect(JSON.parse(response.body)['error']).to include('Rate limit exceeded')
    end
    
    it 'adds rate limit headers' do
      response = request.get('/api/v1/products')
      expect(response.headers['X-RateLimit-Limit']).to eq(limit.to_s)
      expect(response.headers['X-RateLimit-Remaining']).to eq((limit - 1).to_s)
      expect(response.headers['X-RateLimit-Reset']).to be_present
    end
  end
  
  describe 'client identification' do
    it 'differentiates between clients' do
      # First request from client A
      headers_a = { 'HTTP_AUTHORIZATION' => 'Bearer token_a' }
      3.times do
        response = request.get('/api/v1/products', headers_a)
        expect(response.status).to eq(200)
      end
      
      # Allow different JWT token/user to be returned for client B
      allow(DataBridgeShared::Auth::JwtHelper).to receive(:decode).and_return([{'user_id' => 2}])
      
      # Requests from client B should have separate counter
      headers_b = { 'HTTP_AUTHORIZATION' => 'Bearer token_b' }
      4.times do
        response = request.get('/api/v1/products', headers_b)
        expect(response.status).to eq(200)
      end
      
      # Reset mock to client A
      allow(DataBridgeShared::Auth::JwtHelper).to receive(:decode).and_return([{'user_id' => 1}])
      
      # Client A should hit limit after 2 more requests
      2.times do
        response = request.get('/api/v1/products', headers_a)
        expect(response.status).to eq(200)
      end
      
      response = request.get('/api/v1/products', headers_a)
      expect(response.status).to eq(429)
      
      # But client B should still be allowed
      allow(DataBridgeShared::Auth::JwtHelper).to receive(:decode).and_return([{'user_id' => 2}])
      response = request.get('/api/v1/products', headers_b)
      expect(response.status).to eq(200)
    end
  end
  
  describe 'path exclusions' do
    it 'skips rate limiting for root path' do
      (limit + 3).times do
        response = request.get('/')
        expect(response.status).to eq(200)
      end
    end
    
    it 'skips rate limiting for API docs' do
      (limit + 3).times do
        response = request.get('/api-docs/index.html')
        expect(response.status).to eq(200)
      end
    end
  end
end