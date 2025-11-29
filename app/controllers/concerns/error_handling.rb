module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
  end

  private

  def render_unprocessable_entity(exception)
    render_error("Validation failed.", status: :unprocessable_entity, details: exception.record.errors.full_messages)
  end
end

