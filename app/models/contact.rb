class Contact < ActiveRecord::Base
  attr_accessible :email, :phone, :message, :name
  validates_presence_of :name, :message
end
