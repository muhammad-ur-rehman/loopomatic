module Services
  class VehicleModelsClient
    BASE_URL = "https://vpic.nhtsa.dot.gov/api/vehicles/getmodelsformakeyear".freeze

    def self.fetch_models(make:, year:)
      new.fetch_models(make: make, year: year)
    end

    def fetch_models(make:, year:)
      url = build_url(make, year)
      response = make_request(url)

      return [] unless response

      normalize_response(response)
    rescue StandardError => e
      Rails.logger.error("Vehicle Models API error: #{e.message}")
      []
    end

    private

    def build_url(make, year)
      "#{BASE_URL}/make/#{make}/modelyear/#{year}?format=json"
    end

    def make_request(url)
      response = Faraday.get(url)

      return nil unless response.status == 200

      JSON.parse(response.body)
    rescue StandardError => e
      Rails.logger.error("Failed to fetch vehicle models: #{e.message}")
      nil
    end

    def normalize_response(response)
      results = response['Results'] || []

      results.map do |result|
        {
          model_id: result['Model_ID'],
          model_name: result['Model_Name'],
          make_id: result['Make_ID'],
          make_name: result['Make_Name']
        }
      end
    end
  end
end

