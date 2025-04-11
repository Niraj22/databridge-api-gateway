# app/services/order_service_client.rb
class OrderServiceClient < ServiceClient
  def initialize
    super(:order)
  end
  
  # Order endpoints
  def get_orders(params = {})
    get('/api/v1/orders', params)
  end
  
  def get_order(id)
    get("/api/v1/orders/#{id}")
  end
  
  def create_order(order_params)
    post('/api/v1/orders', order_params)
  end
  
  def update_order(id, order_params)
    put("/api/v1/orders/#{id}", order_params)
  end
  
  def delete_order(id)
    delete("/api/v1/orders/#{id}")
  end
  
  # Payment endpoints
  def get_payments(order_id)
    get("/api/v1/orders/#{order_id}/payments")
  end
  
  def create_payment(order_id, payment_params)
    post("/api/v1/orders/#{order_id}/payments", payment_params)
  end
  
  # Shipment endpoints
  def get_shipments(order_id)
    get("/api/v1/orders/#{order_id}/shipments")
  end
  
  def create_shipment(order_id, shipment_params)
    post("/api/v1/orders/#{order_id}/shipments", shipment_params)
  end
  
  def update_shipment(order_id, shipment_id, shipment_params)
    put("/api/v1/orders/#{order_id}/shipments/#{shipment_id}", shipment_params)
  end
end