class Payment < ActiveRecord::Base
  validates_presence_of :amount, :date
  belongs_to :customer
  attr_accessible :customer_id, :amount, :date
end
