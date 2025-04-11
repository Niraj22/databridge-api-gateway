# app/services/customer_service_client.rb
class CustomerServiceClient < ServiceClient
  def initialize
    super(:customer)
  end
  
  # Authentication endpoints
  def authenticate(email, password)
    post('/api/auth/login', { email: email, password: password })
  end
  
  def register(user_params)
    post('/api/auth/register', user_params)
  end
  
  # Customer endpoints
  def get_customers(params = {})
    get('/api/customers', params)
  end
  
  def get_customer(id)
    get("/api/customers/#{id}")
  end
  
  def create_customer(customer_params)
    post('/api/customers', customer_params)
  end
  
  def update_customer(id, customer_params)
    put("/api/customers/#{id}", customer_params)
  end
  
  def delete_customer(id)
    delete("/api/customers/#{id}")
  end

  # Address endpoints
  def get_addresses(customer_id)
    get("/api/customers/#{customer_id}/addresses")
  end
  
  def get_address(customer_id, address_id)
    get("/api/customers/#{customer_id}/addresses/#{address_id}")
  end
  
  def create_address(customer_id, address_params)
    post("/api/customers/#{customer_id}/addresses", address_params)
  end
  
  def update_address(customer_id, address_id, address_params)
    put("/api/customers/#{customer_id}/addresses/#{address_id}", address_params)
  end
  
  def delete_address(customer_id, address_id)
    delete("/api/customers/#{customer_id}/addresses/#{address_id}")
  end
  
  # Preference endpoints
  def get_preferences(customer_id)
    get("/api/customers/#{customer_id}/preferences")
  end
  
  def get_preference(customer_id, key)
    get("/api/customers/#{customer_id}/preferences/#{key}")
  end
  
  def update_preference(customer_id, key, value)
    put("/api/customers/#{customer_id}/preferences/#{key}", { value: value })
  end
  
  def delete_preference(customer_id, key)
    delete("/api/customers/#{customer_id}/preferences/#{key}")
  end
end