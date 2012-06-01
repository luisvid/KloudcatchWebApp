class AddStorageToDroplets < ActiveRecord::Migration
  change_table :droplets do |t|
    t.string :storage
  end
end
