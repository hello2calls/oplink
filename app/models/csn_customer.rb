class CsnCustomer < ActiveRecord::Base
  attr_accessible :expiration_date, :activation_date, :city, :country, :customer_id, :email, :expiration_date, :first, :last, :phone
  validates_uniqueness_of :customer_id
end
