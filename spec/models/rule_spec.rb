require "rails_helper"

RSpec.describe Rule, type: :model do
  describe "validations" do
    it "requires name, priority, and active flag" do
      rule = described_class.new

      expect(rule).not_to be_valid
      expect(rule.errors[:name]).to include("can't be blank")
      expect(rule.errors[:priority]).to include("is not a number")
      expect(rule.errors[:active]).to include("is not included in the list")
    end
  end

  describe ".active_by_priority" do
    it "returns active rules ordered by priority" do
      create(:rule, name: "High", priority: 1, active: true)
      create(:rule, name: "Low", priority: 5, active: true)
      create(:rule, name: "Inactive", priority: 0, active: false)

      result = described_class.active_by_priority

      expect(result.map(&:name)).to eq(["High", "Low"])
    end
  end
end

