class Payment < ActiveRecord::Base
  validates_presence_of :amount, :date
  belongs_to :customer
  belongs_to :opu
  attr_accessible :customer_id, :amount, :date, :opu_sn, :opu_id
end
