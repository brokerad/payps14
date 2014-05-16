class SetAdStates < ActiveRecord::Migration
  def self.up
    Ad.find_each do |ad|
      ad_state = ad.build_ad_state
      ad_state.state = AdState::APPROVED
      ad_state.save
    end
  end

  def self.down
  end
end
