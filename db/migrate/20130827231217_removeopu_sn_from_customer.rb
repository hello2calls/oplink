class RemoveopuSnFromCustomer < ActiveRecord::Migration
  def change
    remove_column :customers, :opu_sn
  end
end
