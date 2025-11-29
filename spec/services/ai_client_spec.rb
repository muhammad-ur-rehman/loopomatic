require "rails_helper"

RSpec.describe Services::AiClient do
  describe ".classify" do
    it "classifies defect items" do
      result = described_class.classify(description: "Broken cover and not working", reason: "damaged")

      expect(result[:category]).to eq("defect_item")
      expect(result[:confidence]).to be > 0.8
      expect(result[:tags]).to include("hardware_issue")
    end

    it "classifies size issues" do
      result = described_class.classify(description: "Smaller than expected size", reason: "too_small")

      expect(result[:category]).to eq("size_issue")
    end

    it "classifies changed mind" do
      result = described_class.classify(description: "Ordered two variants, kept the other", reason: "changed_mind")

      expect(result[:category]).to eq("no_issue_change_of_mind")
    end
  end
end

