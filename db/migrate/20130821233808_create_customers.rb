class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :status
      t.string :phone
      t.string :opu_sn
      t.datetime :activation_date
      t.datetime :expiration_date
      t.string :first
      t.string :last
      t.string :city
      t.string :country
      t.string :email
      t.string :address
      t.float :balance

      t.timestamps
    end
  end
end
