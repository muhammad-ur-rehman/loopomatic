require 'set'

module Services
  class DiscontinuedModelsCalculator
    GAP_YEARS = 2

    def self.calculate(make:, from_year:, to_year:, gap_years: GAP_YEARS)
      new.calculate(make: make, from_year: from_year, to_year: to_year, gap_years: gap_years)
    end

    def initialize
      @warnings = []
    end

    def calculate(make:, from_year:, to_year:, gap_years:)
      @make = make
      @from_year = from_year
      @to_year = to_year
      @gap_years = gap_years

      validate_inputs

      models_by_year = fetch_models_for_all_years
      discontinued = find_discontinued_models(models_by_year)

      {
        make: make,
        from_year: from_year,
        to_year: to_year,
        gap_years: gap_years,
        discontinued_models: discontinued,
        warnings: @warnings
      }
    end

    private

    attr_reader :make, :from_year, :to_year, :gap_years

    def validate_inputs
      raise ArgumentError, 'from_year must be less than to_year' if from_year >= to_year
      raise ArgumentError, 'gap_years must be positive' if gap_years <= 0
      raise ArgumentError, 'Not enough years in range' if (to_year - from_year) < gap_years
    end

    def fetch_models_for_all_years
      models_by_year = {}

      (from_year..to_year).each do |year|
        models = Services::VehicleModelsClient.fetch_models(make: make, year: year)

        if models.empty?
          @warnings << "No models found or API error for year #{year}"
        else
          models_by_year[year] = models.map { |m| m[:model_name] }.uniq
        end
      end

      models_by_year
    end

    def find_discontinued_models(models_by_year)
      early_period_end = to_year - gap_years
      late_period_start = to_year - gap_years + 1

      early_models = Set.new
      (from_year..early_period_end).each do |year|
        models_by_year[year]&.each { |model| early_models.add(model) }
      end

      late_models = Set.new
      (late_period_start..to_year).each do |year|
        models_by_year[year]&.each { |model| late_models.add(model) }
      end

      early_models.reject { |model| late_models.include?(model) }.to_a.sort
    end
  end
end

