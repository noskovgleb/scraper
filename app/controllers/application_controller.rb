class ApplicationController < ActionController::API
  # Add a before_action to set default headers
  before_action :set_default_response_format

  # Handle common errors at the application level
  rescue_from ActionController::ParameterMissing, with: :render_parameter_missing
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::RoutingError, with: :render_not_found
  rescue_from ActionController::BadRequest, with: :render_bad_request

  private

  def set_default_response_format
    request.format = :json unless params[:format]
  end

  def render_parameter_missing(exception)
    render_error(exception.message, :bad_request)
  end

  def render_not_found(exception)
    render_error(exception.message || "Resource not found", :not_found)
  end

  def render_bad_request(exception)
    render_error(exception.message, :bad_request)
  end

  # Standardized error response format
  def render_error(message, status = :internal_server_error, details = nil)
    response = {
      error: {
        message: message,
        status: Rack::Utils::SYMBOL_TO_STATUS_CODE[status]
      }
    }

    # Add details if provided
    response[:error][:details] = details if details

    # Add request_id for tracking
    response[:error][:request_id] = request.request_id if request.respond_to?(:request_id)

    render json: response, status: status
  end
end
