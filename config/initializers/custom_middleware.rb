class Authentication
  def initialize(app)
    @app = app
  end
  
  def call(env)
    @app.call(env)
  end
end

class RateLimiting
  def initialize(app)
    @app = app
  end
  
  def call(env)
    @app.call(env)
  end
end

Rails.application.configure do
  config.middleware.use RateLimiting
end
