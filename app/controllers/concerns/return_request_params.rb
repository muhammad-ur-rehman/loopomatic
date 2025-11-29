module ReturnRequestParams
  extend ActiveSupport::Concern

  private

  def parsed_return_request_params
    attributes = return_request_params.to_h
    attributes[:metadata] = parse_metadata(attributes[:metadata])
    attributes
  end

  def parse_metadata(metadata)
    return metadata if metadata.blank? || metadata.is_a?(Hash)

    JSON.parse(metadata)
  rescue JSON::ParserError
    {}
  end

  def success_payload_for(request)
    {
      return_request: request,
      message: "Return request processing has been queued. Check back shortly for AI decision."
    }
  end

  def respond_with_request_errors(record)
    respond_to do |format|
      format.json { render_error(record.errors.full_messages, status: :unprocessable_entity) }
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end

