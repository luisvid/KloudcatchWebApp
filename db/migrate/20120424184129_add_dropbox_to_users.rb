class AddDropboxToUsers < ActiveRecord::Migration
  change_table :users do |t|
    t.boolean :delete_files, :default => false
    t.string :dropbox_access_token
  end
end
