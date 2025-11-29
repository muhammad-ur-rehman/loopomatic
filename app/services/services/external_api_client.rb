module Services
  class ExternalApiClient
    COUNTRY_API_BASE = 'https://restcountries.com/v3.1/alpha'.freeze

    def self.enrich(return_request)
      new(return_request).enrich
    end

    def initialize(return_request)
      @return_request = return_request
      @metadata = (return_request.metadata || {}).with_indifferent_access
      @metadata_changed = false
    end

    def enrich
      enrich_country_data if country_code.present?
      enrich_risk_score

      return_request.update(metadata: @metadata.to_h) if @metadata_changed
      @metadata
    end

    private

    attr_reader :return_request

    def country_code
      @metadata['country']
    end

    def enrich_country_data
      return if country_code.blank?

      begin
        response = fetch_country_data(country_code)
        if response && response[:name]
          @metadata[:country_data] = {
            name: response[:name][:common],
            region: response[:region],
            subregion: response[:subregion],
            currency: response[:currencies]&.values&.first&.dig('name')
          }
          @metadata_changed = true
        end
      rescue StandardError => e
        Rails.logger.error("Failed to enrich country data: #{e.message}")
      end
    end

    def enrich_risk_score
      risk_score = calculate_risk_score
      @metadata[:risk_score] = risk_score
      @metadata[:risk_level] = risk_level(risk_score)
      @metadata_changed = true
    end

    def calculate_risk_score
      score = 0.5

      if return_request.order_value_cents > 10_000
        score += 0.2
      elsif return_request.order_value_cents > 5_000
        score += 0.1
      end

      case return_request.reason
      when 'damaged', 'defective'
        score -= 0.1
      when 'changed_mind'
        score += 0.1
      end

      [[score, 0.0].max, 1.0].min
    end

    def risk_level(score)
      case score
      when 0.0...0.3
        'low'
      when 0.3...0.7
        'medium'
      else
        'high'
      end
    end

    def fetch_country_data(country_code)
      url = "#{COUNTRY_API_BASE}/#{country_code.upcase}"
      response = Faraday.get(url)

      return nil unless response.status == 200

      JSON.parse(response.body, symbolize_names: true).first
    rescue StandardError => e
      Rails.logger.error("Country API error: #{e.message}")
      nil
    end
  end
end
