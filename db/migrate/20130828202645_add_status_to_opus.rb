class AddStatusToOpus < ActiveRecord::Migration
  def change
    add_column :opus, :status, :string
  end
end
