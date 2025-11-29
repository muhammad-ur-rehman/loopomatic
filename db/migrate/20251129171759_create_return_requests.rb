class CreateReturnRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :return_requests do |t|
      t.string :order_id
      t.string :customer_id
      t.integer :order_value_cents
      t.string :currency
      t.string :reason
      t.text :description
      t.jsonb :ai_classification
      t.string :decision
      t.string :resolution
      t.jsonb :metadata

      t.timestamps
    end
  end
end
