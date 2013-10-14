class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.belongs_to :customer
      t.belongs_to :opu
      t.float :amount
      t.datetime :date

      t.timestamps
    end
  end
end
