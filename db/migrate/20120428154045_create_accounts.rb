class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :storage_size, :default => "0"
      t.string :storage_unit, :default => "GB"
      t.string :cost
      t.string :period, :default => "month"
      t.string :currency, :default => "USD"
      t.string :description

      t.timestamps
    end
  end
end
