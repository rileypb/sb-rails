class AddOAuthSubToUser < ActiveRecord::Migration[6.1]
  def change
  	add_column :users, :oauthsub, :string
  end
end
