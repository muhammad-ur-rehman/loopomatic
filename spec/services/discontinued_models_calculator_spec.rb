require "rails_helper"

RSpec.describe Services::DiscontinuedModelsCalculator do
  describe "#calculate" do
    let(:calculator) { described_class.new }

    before do
      allow(Services::VehicleModelsClient).to receive(:fetch_models) do |make:, year:|
        case year
        when 2011..2018
          [{ model_name: "Model A" }, { model_name: "Model B" }]
        when 2019..2020
          [{ model_name: "Model A" }]
        else
          []
        end
      end
    end

    it "returns models missing in the late period" do
      result = calculator.calculate(make: "honda", from_year: 2011, to_year: 2020, gap_years: 2)

      expect(result[:discontinued_models]).to contain_exactly("Model B")
      expect(result[:warnings]).to all(be_a(String)).or be_empty
    end

    it "raises error for invalid window" do
      expect do
        calculator.calculate(make: "honda", from_year: 2020, to_year: 2019, gap_years: 2)
      end.to raise_error(ArgumentError)
    end
  end
end

