class CreateBotUserAgents < ActiveRecord::Migration
  def self.up
    create_table :bot_user_agents do |t|
  		t.string 	:user_agent
  		t.boolean	:active
      t.timestamps
    end

		BotUserAgent.create!(
			:user_agent => "facebookexternalhit",
			:active => true)  
  end

  def self.down
    drop_table :bot_user_agents
  end
  
end
