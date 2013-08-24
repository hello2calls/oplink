class Customer < ActiveRecord::Base
  validates_presence_of :activation_date, :address, :balance, :city, :country, :email, :first, :last, :opu_sn, :phone
  validates_uniqueness_of :opu_sn
  has_many :payments, :dependent => :destroy
  attr_accessible :activation_date, :address, :balance, :city, :country, :email, :expiration_date, :status, :first, :last, :opu_sn, :phone
end
