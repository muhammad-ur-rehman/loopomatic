FactoryBot.define do
  factory :rule do
    sequence(:name) { |n| "Rule #{n}" }
    priority { 1 }
    active { true }
    conditions { { "all" => [{ "field" => "order_value_cents", "operator" => ">", "value" => 5000 }] } }
    actions { { "set_decision" => "approved" } }
  end
end

