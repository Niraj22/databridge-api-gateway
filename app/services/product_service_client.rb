# app/services/product_service_client.rb
class ProductServiceClient < ServiceClient
  def initialize
    super(:product)
  end
  
  def get_products(params = {})
    get('/api/products', params)
  end
  
  def get_product(id)
    get("/api/products/#{id}")
  end
  
  def create_product(product_params)
    post('/api/products', product_params)
  end
  
  def update_product(id, product_params)
    put("/api/products/#{id}", product_params)
  end
  
  def delete_product(id)
    delete("/api/products/#{id}")
  end
end
