class Opu < ActiveRecord::Base
  attr_accessor :activation_date, :customer_id, :expiration_date, :sn, :status
  validates_presence_of :sn, :customer_id
  validates_uniqueness_of :sn
  belongs_to :customer
  has_many :payments, :dependent => :destroy
end
