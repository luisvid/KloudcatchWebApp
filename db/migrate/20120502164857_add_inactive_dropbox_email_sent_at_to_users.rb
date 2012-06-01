class AddInactiveDropboxEmailSentAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :inactive_dropbox_email_sent_at, :datetime, :default => nil
  end
end
