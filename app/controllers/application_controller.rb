class ApplicationController < ActionController::API
  # Add a before_action to set default headers
  before_action :set_default_response_format
  
  # Handle common errors at the application level
  rescue_from ActionController::ParameterMissing, with: :render_parameter_missing
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::RoutingError, with: :render_not_found
  
  private
  
  def set_default_response_format
    request.format = :json unless params[:format]
  end
  
  def render_parameter_missing(exception)
    render json: { error: exception.message }, status: :bad_request
  end
  
  def render_not_found(exception)
    render json: { error: exception.message || 'Resource not found' }, status: :not_found
  end
end
