class CreateOpus < ActiveRecord::Migration
  def change
    create_table :opus do |t|
      t.integer :customer_id
      t.string :sn
      t.datetime :activation_date
      t.datetime :expiration_date

      t.timestamps
    end
  end
end
