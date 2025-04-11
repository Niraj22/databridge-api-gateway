class RequestStoreMiddleware
    def initialize(app)
      @app = app
    end
    
    def call(env)
      RequestStore.store[:current_request] = ActionDispatch::Request.new(env)
      @app.call(env)
    ensure
      RequestStore.clear!
    end
  end