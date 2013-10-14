class CreateCsnCustomers < ActiveRecord::Migration
  def change
    create_table :csn_customers do |t|
      t.datetime :activation_date
      t.datetime :expiration_date
      t.string :address
      t.string :first
      t.string :last
      t.string :email
      t.string :city
      t.string :country
      t.string :phone
      t.integer :customer_id

      t.timestamps
    end
  end
end
