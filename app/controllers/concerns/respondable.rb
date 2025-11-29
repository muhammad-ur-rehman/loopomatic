module Respondable
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :render_internal_error
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  end

  def render_success(data = {}, status: :ok)
    render json: data, status: status
  end

  def render_error(message, status: :bad_request, details: nil)
    payload = { error: message }
    payload[:details] = details if details
    render json: payload, status: status
  end

  private

  def render_internal_error(exception)
    Rails.logger.error("[API ERROR] #{exception.class}: #{exception.message}\n#{exception.backtrace&.first(10)&.join("\n")}")
    render_error("An unexpected error occurred.", status: :internal_server_error)
  end

  def render_not_found(exception)
    render_error(exception.message, status: :not_found)
  end
end

