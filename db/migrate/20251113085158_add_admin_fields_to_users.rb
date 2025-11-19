class AddAdminFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :string, default: 'user'
    add_column :users, :permissions, :text
    
    # Đảm bảo các index
    add_index :users, :role
  end
end