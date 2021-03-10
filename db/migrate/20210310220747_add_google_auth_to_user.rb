class AddGoogleAuthToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users,  :google_auth, :jsonb
  end
end
