module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :render_internal_server_error
    rescue_from ArgumentError, with: :render_argument_error
    rescue_from ActionController::ParameterMissing, with: :render_bad_request
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  end

  private

  def render_not_found(exception)
    render json: {
      error: {
        type: 'not_found',
        message: exception.message,
        timestamp: Time.current.iso8601
      }
    }, status: :not_found
  end

  def render_unprocessable_entity(exception)
    render json: {
      error: {
        type: 'validation_error',
        message: exception.record.errors.full_messages.to_sentence,
        details: exception.record.errors.as_json,
        timestamp: Time.current.iso8601
      }
    }, status: :unprocessable_entity
  end

  def render_bad_request(exception)
    render json: {
      error: {
        type: 'bad_request',
        message: exception.message,
        timestamp: Time.current.iso8601
      }
    }, status: :bad_request
  end

  def render_argument_error(exception)
    Rails.logger.error "ArgumentError: #{exception.message}"
    render json: {
      error: {
        type: 'validation_error',
        message: 'Invalid parameter value',
        timestamp: Time.current.iso8601
      }
    }, status: :unprocessable_entity
  end

  def render_internal_server_error(exception)
    Rails.logger.error "Internal Server Error: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n") if exception.backtrace

    render json: {
      error: {
        type: 'internal_server_error',
        message: 'An unexpected error occurred',
        timestamp: Time.current.iso8601
      }
    }, status: :internal_server_error
  end

  def render_error(message, status = :unprocessable_entity)
    render json: {
      error: {
        type: 'error',
        message: message,
        timestamp: Time.current.iso8601
      }
    }, status: status
  end
end
