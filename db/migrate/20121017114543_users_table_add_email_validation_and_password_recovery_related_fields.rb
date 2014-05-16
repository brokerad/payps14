class UsersTableAddEmailValidationAndPasswordRecoveryRelatedFields < ActiveRecord::Migration
  def self.up
    add_column :users, :email_token, :string
    add_column :users, :email_token_exp, :datetime
    add_column :users, :is_email_confirmed, :boolean, :default => false
    add_column :users, :password_token, :string
    add_column :users, :password_token_exp, :datetime
  end

  def self.down
    remove_column :users, :email_token
    remove_column :users, :email_token_exp
    remove_column :users, :is_email_confirmed
    remove_column :users, :password_token
    remove_column :users, :password_token_exp
  end
end
