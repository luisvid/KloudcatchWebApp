class AddPasswordHintToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_hint, :string
  end
end
