class AddAccountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :account_id, :integer, :default => nil
  end
end
