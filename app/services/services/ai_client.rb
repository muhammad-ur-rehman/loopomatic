module Services
  class AiClient
    def self.classify(description:, reason:)
      new(description: description, reason: reason).classify
    end

    def initialize(description:, reason:)
      @description = description.to_s.downcase
      @reason = reason.to_s.downcase
    end

    def classify
      category = determine_category
      confidence = calculate_confidence(category)
      tags = determine_tags(category)

      {
        category: category,
        confidence: confidence,
        tags: tags
      }
    end

    private

    attr_reader :description, :reason

    def determine_category
      # TODO we can use AI to determine category
      if defect_keywords.any? { |keyword| description.include?(keyword) }
        "defect_item"
      elsif size_keywords.any? { |keyword| description.include?(keyword) } || %w[too_small too_large].include?(reason)
        "size_issue"
      elsif changed_mind_keywords.any? { |keyword| description.include?(keyword) } || reason == "changed_mind"
        "no_issue_change_of_mind"
      else
        "other"
      end
    end

    def calculate_confidence(category)
      # TODO we can use AI to calculate confidence
      base_confidence = 0.85

      case category
      when "defect_item"
        base_confidence += 0.09 if reason == "damaged"
      when "size_issue"
        base_confidence += 0.03 if %w[too_small too_large].include?(reason)
      when "no_issue_change_of_mind"
        base_confidence += 0.06 if reason == "changed_mind"
      end

      [base_confidence, 0.99].min
    end

    def determine_tags(category)
      tags = []
      # TODO we can use AI to determine tags
      case category
      when "defect_item"
        tags << "hardware_issue" if description.include?("broken") || description.include?("not working")
        tags << "not_functioning" if description.include?("not turning") || description.include?("not working")
        tags << "damaged" if description.include?("damaged") || description.include?("broken")
      when "size_issue"
        tags << "fit" if description.include?("fit") || description.include?("size")
        tags << "customer_expectation" if description.include?("expected") || description.include?("usually")
      when "no_issue_change_of_mind"
        tags << "no_defect"
      end

      tags.uniq
    end

    def defect_keywords
      %w[broken damaged defect faulty not working not turning malfunction broken cover]
    end

    def size_keywords
      %w[smaller larger bigger size fit too small too large expected usually wear]
    end

    def changed_mind_keywords
      %w[decided keep other variant ordered two keep the other]
    end
  end
end

