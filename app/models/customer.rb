class Customer < ActiveRecord::Base
  validates_presence_of :activation_date, :balance, :country, :email, :first, :last, :phone
  validates_uniqueness_of :email
  has_many :payments, through: :opus, :dependent => :destroy
  has_many :opus, :dependent => :destroy
  attr_accessor :activation_date, :address, :balance, :city, :country, :email, :expiration_date, :status, :first, :last, :phone
end
