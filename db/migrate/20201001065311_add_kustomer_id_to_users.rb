class AddKustomerIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_users, :kustomer_id, :string
    add_index :spree_users, :kustomer_id
  end
end
