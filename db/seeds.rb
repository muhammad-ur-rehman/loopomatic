Rule.find_or_create_by!(name: 'High-Value Defect - Auto Approve Refund') do |rule|
  rule.priority = 1
  rule.active = true
  rule.conditions = {
    'all' => [
      { 'field' => 'order_value_cents', 'operator' => '>', 'value' => 10_000 },
      { 'field' => 'ai_classification.category', 'operator' => '=', 'value' => 'defect_item' }
    ]
  }
  rule.actions = {
    'set_decision' => 'approved',
    'set_resolution' => 'refund'
  }
end

Rule.find_or_create_by!(name: 'Size Issue - Auto Approve Exchange') do |rule|
  rule.priority = 2
  rule.active = true
  rule.conditions = {
    'all' => [
      { 'field' => 'ai_classification.category', 'operator' => '=', 'value' => 'size_issue' }
    ]
  }
  rule.actions = {
    'set_decision' => 'approved',
    'set_resolution' => 'exchange'
  }
end

Rule.find_or_create_by!(name: 'Changed Mind - Manual Review') do |rule|
  rule.priority = 3
  rule.active = true
  rule.conditions = {
    'all' => [
      { 'field' => 'ai_classification.category', 'operator' => '=', 'value' => 'no_issue_change_of_mind' }
    ]
  }
  rule.actions = {
    'set_decision' => 'manual_review',
    'set_resolution' => 'none'
  }
end

Rule.find_or_create_by!(name: 'Low-Value Defect - Auto Approve Refund') do |rule|
  rule.priority = 4
  rule.active = true
  rule.conditions = {
    'all' => [
      { 'field' => 'order_value_cents', 'operator' => '<=', 'value' => 10_000 },
      { 'field' => 'ai_classification.category', 'operator' => '=', 'value' => 'defect_item' }
    ]
  }
  rule.actions = {
    'set_decision' => 'approved',
    'set_resolution' => 'refund'
  }
end

puts "Seeded #{Rule.count} rules"
