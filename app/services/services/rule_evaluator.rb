module Services
  class RuleEvaluator
    def self.evaluate(return_request, rule)
      new(return_request, rule).evaluate
    end

    def initialize(return_request, rule)
      @return_request = return_request
      @rule = rule
      @conditions = rule.conditions || {}
      @actions = rule.actions || {}
    end

    def evaluate
      return false unless matches_conditions?

      apply_actions
      true
    end

    private

    attr_reader :return_request, :rule, :conditions, :actions

    def matches_conditions?
      return true if conditions.empty?

      if conditions.key?("all")
        evaluate_all_conditions(conditions["all"])
      elsif conditions.key?("any")
        evaluate_any_conditions(conditions["any"])
      else
        evaluate_all_conditions([conditions])
      end
    end

    def evaluate_all_conditions(condition_list)
      condition_list.all? { |condition| evaluate_condition(condition) }
    end

    def evaluate_any_conditions(condition_list)
      condition_list.any? { |condition| evaluate_condition(condition) }
    end

    def evaluate_condition(condition)
      field = condition["field"]
      operator = condition["operator"]
      value = condition["value"]

      return false if field.nil? || operator.nil?

      field_value = get_field_value(field)

      case operator
      when "="
        field_value == value
      when ">"
        field_value.to_f > value.to_f
      when "<"
        field_value.to_f < value.to_f
      when ">="
        field_value.to_f >= value.to_f
      when "<="
        field_value.to_f <= value.to_f
      when "!="
        field_value != value
      when "includes", "contains"
        field_value.to_s.include?(value.to_s)
      else
        false
      end
    end

    def get_field_value(field_path)
      parts = field_path.split(".")
      value = return_request

      parts.each do |part|
        if value.is_a?(Hash)
          value = value[part] || value[part.to_sym]
        elsif value.respond_to?(part)
          value = value.public_send(part)
        else
          return nil
        end
      end

      value
    end

    def apply_actions
      actions.each do |action_key, action_value|
        case action_key
        when "set_decision"
          return_request.update(decision: action_value)
        when "set_resolution"
          return_request.update(resolution: action_value)
        when "set_metadata"
          existing_metadata = (return_request.metadata || {}).with_indifferent_access
          merged_metadata = existing_metadata.merge(action_value)
          return_request.update(metadata: merged_metadata.to_h)
        end
      end
    end
  end
end

