class Account < ActiveRecord::Base
  has_many :users
  attr_accessible :name, :storage_size, :storage_unit, :cost, :period, :currency, :description
end
