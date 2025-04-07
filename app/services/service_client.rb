# app/services/service_client.rb
class ServiceClient
  attr_reader :service_name
  
  def initialize(service_name)
    @service_name = service_name
  end
  
  def get(path, params = {})
    response = connection.get(path, params)
    handle_response(response)
  end
  
  def post(path, params = {})
    response = connection.post(path) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = params.to_json
    end
    handle_response(response)
  end
  
  def put(path, params = {})
    response = connection.put(path) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = params.to_json
    end
    handle_response(response)
  end
  
  def delete(path, params = {})
    response = connection.delete(path, params)
    handle_response(response)
  end
  
  private
  
  def connection
    @connection ||= Faraday.new(url: service_url) do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end
  end
  
  def service_url
    ServiceRegistry.service_url(service_name)
  end
  
  def handle_response(response)
    return JSON.parse(response.body) if response.status.between?(200, 299)
    
    # Handle errors
    case response.status
    when 401
      raise UnauthorizedError, "Unauthorized request to #{service_name} service"
    when 404
      raise ResourceNotFoundError, "Resource not found in #{service_name} service"
    else
      raise ServiceError, "Error from #{service_name} service: #{response.body}"
    end
  end
  
  class ServiceError < StandardError; end
  class UnauthorizedError < ServiceError; end
  class ResourceNotFoundError < ServiceError; end
end
