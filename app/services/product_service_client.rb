# app/services/product_service_client.rb
class ProductServiceClient < ServiceClient
  def initialize
    super(:product)
  end
  
  def get_products(params = {})
    get('/api/v1/products', params)
  end
  
  def get_product(id)
    get("/api/v1/products/#{id}")
  end
  
  def create_product(product_params)
    post('/api/v1/products', product_params)
  end
  
  def update_product(id, product_params)
    put("/api/v1/products/#{id}", product_params)
  end
  
  def delete_product(id)
    delete("/api/v1/products/#{id}")
  end
  
  # Category methods
  def get_categories(params = {})
    get('/api/v1/categories', params)
  end
  
  def get_category(id)
    get("/api/v1/categories/#{id}")
  end
  
  def create_category(category_params)
    post('/api/v1/categories', category_params)
  end
  
  def update_category(id, category_params)
    put("/api/v1/categories/#{id}", category_params)
  end
  
  def delete_category(id)
    delete("/api/v1/categories/#{id}")
  end
  
  # Inventory methods
  def get_product_inventory(product_id)
    get("/api/v1/products/#{product_id}/inventory")
  end
  
  def update_product_inventory(product_id, inventory_params)
    put("/api/v1/products/#{product_id}/inventory", inventory_params)
  end
  
  def batch_update_inventory(inventory_params)
    post('/api/v1/inventories/batch', inventory_params)
  end
end