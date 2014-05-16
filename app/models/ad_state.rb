class AdState < ActiveRecord::Base
  PENDING = "pending"
  APPROVED = "approved"
  REJECTED = "rejected"

  belongs_to :ad
end
