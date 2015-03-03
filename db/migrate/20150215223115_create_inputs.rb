class CreateInputs < ActiveRecord::Migration
  def change
    create_table :inputs do |t|
      t.string :city
      t.string :state
      t.string :airport

      t.timestamps null: false
    end
  end
end
