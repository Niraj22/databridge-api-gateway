# app/services/order_service_client.rb
class OrderServiceClient < ServiceClient
  def initialize
    super(:order)
  end
  
  def get_orders(params = {})
    get('/api/orders', params)
  end
  
  def get_order(id)
    get("/api/orders/#{id}")
  end
  
  def create_order(order_params)
    post('/api/orders', order_params)
  end
  
  def update_order(id, order_params)
    put("/api/orders/#{id}", order_params)
  end
  
  def delete_order(id)
    delete("/api/orders/#{id}")
  end
end
