require "rails_helper"

RSpec.describe Services::RuleEvaluator do
  let(:return_request) do
    create(
      :return_request,
      order_value_cents: 12_000,
      ai_classification: { "category" => "defect_item" }
    )
  end

  describe ".evaluate" do
    it "applies actions when all conditions match" do
      rule = create(
        :rule,
        conditions: {
          "all" => [
            { "field" => "order_value_cents", "operator" => ">", "value" => 10_000 },
            { "field" => "ai_classification.category", "operator" => "=", "value" => "defect_item" }
          ]
        },
        actions: { "set_decision" => "approved", "set_resolution" => "refund" }
      )

      result = described_class.evaluate(return_request, rule)

      expect(result).to be(true)
      expect(return_request.reload.decision).to eq("approved")
      expect(return_request.reload.resolution).to eq("refund")
    end

    it "returns false when conditions fail" do
      rule = create(:rule, conditions: { "all" => [{ "field" => "order_value_cents", "operator" => "<", "value" => 100 }] })

      result = described_class.evaluate(return_request, rule)

      expect(result).to be(false)
      expect(return_request.reload.decision).to eq("pending")
    end
  end
end

