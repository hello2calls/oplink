class AddOpuSnToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :opu_sn, :string
  end
end
