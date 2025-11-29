module Services
  class ReturnRequestProcessor
    def self.process(return_request)
      new(return_request).process
    end

    def initialize(return_request)
      @return_request = return_request
    end

    def process
      classify_with_ai
      evaluate_rules
      enrich_with_external_api

      return_request.reload
    end

    private

    attr_reader :return_request

    def classify_with_ai
      classification = Services::AiClient.classify(
        description: return_request.description,
        reason: return_request.reason
      )

      return_request.update(ai_classification: classification)
    end

    def evaluate_rules
      rules = Rule.active_by_priority

      rules.each do |rule|
        matched = Services::RuleEvaluator.evaluate(return_request, rule)
        break if matched
      end
    end

    def enrich_with_external_api
      Services::ExternalApiClient.enrich(return_request)
    end
  end
end

