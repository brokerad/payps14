class BotUserAgent < ActiveRecord::Base
  validates :user_agent, :presence => true, :uniqueness => true
  validate :already_as_substring

  def already_as_substring
    agents = BotUserAgent.all
    agents.each do |a|
      errors.add(:user_agent, "already exists as a substring") if a.user_agent.to_s.include? user_agent
    end
  end
  
	def self.active_user_agents
		user_agents = BotUserAgent.where('active = true').map(&:user_agent)		
	end
end
