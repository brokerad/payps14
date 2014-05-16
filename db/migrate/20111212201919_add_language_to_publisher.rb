class AddLanguageToPublisher < ActiveRecord::Migration
  def self.up
    add_column :publishers, :language_id, :integer
  end

  def self.down
    remove_column :publishers, :language_id
  end
end
