# app/services/service_client.rb
class ServiceClient
  attr_reader :service_name
  
  def initialize(service_name)
    @service_name = service_name
  end
  
  def get(path, params = {})
    response = connection.get(path, params) do |req|
      add_auth_header(req)
    end
    handle_response(response)
  end
  
  def post(path, params = {})
    response = connection.post(path) do |req|
      req.headers['Content-Type'] = 'application/json'
      add_auth_header(req)
      req.body = params.to_json
    end
    handle_response(response)
  end
  
  def put(path, params = {})
    response = connection.put(path) do |req|
      req.headers['Content-Type'] = 'application/json'
      add_auth_header(req)
      req.body = params.to_json
    end
    handle_response(response)
  end
  
  def delete(path, params = {})
    response = connection.delete(path) do |req|
      add_auth_header(req)
      req.params.merge!(params) if params.present?
    end
    handle_response(response)
  end
  
  private
  
  def add_auth_header(request)
    # Get the current request from the controller context
    controller_request = RequestStore.store[:current_request]
    
    # Forward the Authorization header if it exists
    if controller_request && controller_request.headers['Authorization']
      request.headers['Authorization'] = controller_request.headers['Authorization']
    end
  end
  
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