class CreateDroplets < ActiveRecord::Migration
  def change
    create_table :droplets do |t|
      t.string :url
      t.string :file
      t.string :name
      t.references :status
      t.references :user

      t.timestamps
    end
  end
end
