FactoryBot.define do
  factory :return_request do
    sequence(:order_id) { |n| "ORD-#{1000 + n}" }
    sequence(:customer_id) { |n| "CUST-#{n}" }
    order_value_cents { 10_000 }
    currency { "EUR" }
    reason { "damaged" }
    description { "Item arrived damaged" }
    decision { "pending" }
    resolution { "none" }
    metadata { { "country" => "DE" } }
  end
end

