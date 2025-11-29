class ReturnRequestProcessorJob < ApplicationJob
  queue_as :default

  def perform(return_request_id)
    return_request = ReturnRequest.find_by(id: return_request_id)
    return unless return_request

    Services::ReturnRequestProcessor.process(return_request)
  end
end

