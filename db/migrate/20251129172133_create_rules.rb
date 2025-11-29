class CreateRules < ActiveRecord::Migration[8.1]
  def change
    create_table :rules do |t|
      t.string :name
      t.integer :priority
      t.boolean :active
      t.jsonb :conditions
      t.jsonb :actions

      t.timestamps
    end
  end
end
