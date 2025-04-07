class ApplicationController < ActionController::API
  rescue_from StandardError, with: :handle_error
  
  private
  
  def handle_error(e)
    case e
    when ActionController::ParameterMissing
      render json: { error: e.message }, status: :bad_request
    when ActiveRecord::RecordNotFound
      render json: { error: 'Resource not found' }, status: :not_found
    else
      Rails.logger.error("Error: #{e.message}\n#{e.backtrace.join("\n")}")
      render json: { error: "Internal Server Error" }, status: :internal_server_error
    end
  end
end
