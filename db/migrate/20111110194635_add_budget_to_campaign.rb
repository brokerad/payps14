class AddBudgetToCampaign < ActiveRecord::Migration
  def self.up
    add_column :campaigns, :budget, :decimal, :precision => 8, :scale => 2
  end

  def self.down
    remove_column :campaigns, :budget
  end
end
