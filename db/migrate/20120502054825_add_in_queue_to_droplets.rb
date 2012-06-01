class AddInQueueToDroplets < ActiveRecord::Migration
  def change
    add_column :droplets, :in_queue, :boolean, :default => false
  end
end
