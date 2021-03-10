class AddMoreOmniauthToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :token, :string
    add_column :users, :refresh_token, :string
    add_column :users, :expires, :string
    add_column :users, :expires_at, :string
  end
end
