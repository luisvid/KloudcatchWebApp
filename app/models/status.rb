class Status < ActiveRecord::Base
  has_many :droplets
  has_many :droplet_histories
end

