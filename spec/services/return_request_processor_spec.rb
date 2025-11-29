require "rails_helper"

RSpec.describe Services::ReturnRequestProcessor do
  describe ".process" do
    it "applies matching rules and updates the record" do
      rule = create(
        :rule,
        conditions: {
          "all" => [
            { "field" => "order_value_cents", "operator" => ">", "value" => 1000 },
            { "field" => "reason", "operator" => "=", "value" => "damaged" }
          ]
        },
        actions: { "set_decision" => "approved", "set_resolution" => "refund" }
      )

      request = create(
        :return_request,
        reason: "damaged",
        order_value_cents: 5000
      )

      described_class.process(request)

      expect(request.reload.decision).to eq("approved")
      expect(request.resolution).to eq("refund")
    end
  end
end

