require "rails_helper"

RSpec.describe ReturnRequestsController, type: :controller do
  before do
    ActiveJob::Base.queue_adapter = :test
  end
  describe "POST /return_requests" do
    let(:valid_params) do
      {
        return_request: {
          order_id: "ORD-2001",
          customer_id: "CUST-123",
          order_value_cents: 15_000,
          currency: "EUR",
          reason: "damaged",
          description: "Broken motor unit",
          metadata: { country: "DE", channel: "online_store" }
        }
      }
    end

    it "enqueues the processing job" do
      expect do
        post :create, params: valid_params, as: :json
      end.to have_enqueued_job(ReturnRequestProcessorJob)
    end
  end
end

