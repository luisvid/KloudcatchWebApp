class CreateDropletHistories < ActiveRecord::Migration
  def change
    create_table :droplet_histories do |t|
      t.references :droplet
      t.references :status
      t.references :user

      t.timestamps
    end
  end
end
