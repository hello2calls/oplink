class AddOpuIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :opu_id, :integer
  end
end
