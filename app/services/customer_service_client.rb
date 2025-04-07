# app/services/customer_service_client.rb
class CustomerServiceClient < ServiceClient
  def initialize
    super(:customer)
  end
  
  def authenticate(email, password)
    post('/api/auth/login', { email: email, password: password })
  end
  
  def get_user(id)
    get("/api/users/#{id}")
  end
  
  def create_user(user_params)
    post('/api/users', user_params)
  end
  
  def update_user(id, user_params)
    put("/api/users/#{id}", user_params)
  end
end
