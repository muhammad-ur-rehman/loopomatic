require "rails_helper"

RSpec.describe ReturnRequest, type: :model do
  describe "validations" do
    it "requires core attributes" do
      record = described_class.new

      expect(record).not_to be_valid
      expect(record.errors[:order_id]).to include("can't be blank")
      expect(record.errors[:customer_id]).to include("can't be blank")
      expect(record.errors[:currency]).to include("can't be blank")
      expect(record.errors[:reason]).to include("can't be blank")
      expect(record.errors[:description]).to include("can't be blank")
    end

    it "requires order_value_cents to be positive" do
      record = build(:return_request, order_value_cents: 0)

      expect(record).not_to be_valid
      expect(record.errors[:order_value_cents]).to include("must be greater than 0")
    end
  end

  describe "enums" do
    it "defines decision states" do
      expect(described_class.decisions.keys).to contain_exactly("pending", "approved", "rejected", "manual_review")
    end

    it "defines resolution states" do
      expect(described_class.resolutions.keys).to contain_exactly("none", "refund", "exchange", "store_credit")
    end
  end
end

