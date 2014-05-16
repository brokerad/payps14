class CleanCoupon < ActiveRecord::Migration
  def self.remove_coupon publisher_id, transaction_id, value
    timestamp = Time.now.utc
    account_id = ActiveRecord::Base.connection.execute("
                  SELECT accounts.id
                  FROM entries
    	              JOIN accounts ON accounts.id = entries.account_id
                  WHERE transaction_id = #{transaction_id} AND parent_id = 13").first['id'].to_i
        
    ActiveRecord::Base.connection.execute("
      INSERT INTO transactions (description, created_at, updated_at) 
      VALUES ('Publisher #{publisher_id} is charged #{value} for multiple coupon request', '#{timestamp}', '#{timestamp}')") 
    
    transaction_id = ActiveRecord::Base.connection.execute("SELECT LASTVAL()").first['lastval'].to_i    
    
    ActiveRecord::Base.connection.execute("
      INSERT INTO entries (amount, account_id, transaction_id, reconciled, created_at, updated_at)
      VALUES (#{(-1)*value}, #{account_id}, #{transaction_id}, TRUE, '#{timestamp}', '#{timestamp}')")
  end

  def self.up
    data = [{:publiser_id => 4160, :transaction_id => 77, :amount => 10.0},
            {:publiser_id => 4160, :transaction_id => 76, :amount => 10.0},
            {:publiser_id => 12975, :transaction_id => 503, :amount => 10.0},
            {:publiser_id => 12975, :transaction_id => 502, :amount => 10.0},
            {:publiser_id => 12975, :transaction_id => 501, :amount => 10.0},
            {:publiser_id => 17279, :transaction_id => 796, :amount => 10.0},
            {:publiser_id => 17658, :transaction_id => 83, :amount => 15.0},
            {:publiser_id => 17658, :transaction_id => 84, :amount => 15.0},
            {:publiser_id => 19350, :transaction_id => 112, :amount => 10.0},
            {:publiser_id => 19350, :transaction_id => 113, :amount => 10.0},
            {:publiser_id => 19680, :transaction_id => 102, :amount => 10.0},
            {:publiser_id => 21129, :transaction_id => 130, :amount => 10.0},
            {:publiser_id => 22509, :transaction_id => 177, :amount => 10.0},
            {:publiser_id => 22509, :transaction_id => 178, :amount => 10.0},
            {:publiser_id => 23235, :transaction_id => 284, :amount => 5.0},
            {:publiser_id => 23235, :transaction_id => 285, :amount => 5.0},
            {:publiser_id => 23235, :transaction_id => 286, :amount => 5.0},
            {:publiser_id => 23235, :transaction_id => 286, :amount => 5.0},
            {:publiser_id => 23235, :transaction_id => 288, :amount => 5.0},
            {:publiser_id => 23313, :transaction_id => 246, :amount => 5.0},
            {:publiser_id => 23313, :transaction_id => 247, :amount => 5.0},
            {:publiser_id => 23313, :transaction_id => 249, :amount => 5.0},
            {:publiser_id => 23875, :transaction_id => 200, :amount => 5.0},
            {:publiser_id => 23875, :transaction_id => 201, :amount => 5.0},
            {:publiser_id => 23875, :transaction_id => 202, :amount => 5.0},
            {:publiser_id => 23885, :transaction_id => 205, :amount => 5.0},
            {:publiser_id => 23885, :transaction_id => 207, :amount => 5.0},
            {:publiser_id => 23911, :transaction_id => 466, :amount => 5.0},
            {:publiser_id => 23954, :transaction_id => 215, :amount => 5.0},
            {:publiser_id => 24096, :transaction_id => 229, :amount => 5.0},
            {:publiser_id => 24096, :transaction_id => 230, :amount => 5.0},
            {:publiser_id => 24135, :transaction_id => 235, :amount => 5.0},
            {:publiser_id => 24135, :transaction_id => 236, :amount => 5.0},
            {:publiser_id => 24155, :transaction_id => 241, :amount => 5.0},
            {:publiser_id => 24155, :transaction_id => 242, :amount => 5.0},
            {:publiser_id => 24172, :transaction_id => 252, :amount => 5.0},
            {:publiser_id => 24172, :transaction_id => 253, :amount => 5.0},
            {:publiser_id => 24172, :transaction_id => 254, :amount => 5.0},
            {:publiser_id => 24172, :transaction_id => 255, :amount => 5.0},
            {:publiser_id => 24172, :transaction_id => 256, :amount => 5.0},
            {:publiser_id => 24218, :transaction_id => 263, :amount => 5.0},
            {:publiser_id => 24218, :transaction_id => 264, :amount => 5.0},
            {:publiser_id => 24218, :transaction_id => 265, :amount => 5.0},
            {:publiser_id => 24252, :transaction_id => 271, :amount => 5.0},
            {:publiser_id => 24362, :transaction_id => 280, :amount => 5.0},
            {:publiser_id => 24362, :transaction_id => 281, :amount => 5.0},
            {:publiser_id => 24406, :transaction_id => 515, :amount => 5.0},
            {:publiser_id => 24420, :transaction_id => 290, :amount => 5.0},
            {:publiser_id => 24534, :transaction_id => 300, :amount => 5.0},
            {:publiser_id => 24548, :transaction_id => 305, :amount => 5.0},
            {:publiser_id => 24744, :transaction_id => 332, :amount => 5.0},
            {:publiser_id => 24900, :transaction_id => 344, :amount => 5.0},
            {:publiser_id => 24900, :transaction_id => 345, :amount => 5.0},  
            {:publiser_id => 24989, :transaction_id => 448, :amount => 5.0},  
            {:publiser_id => 25148, :transaction_id => 382, :amount => 5.0},  
            {:publiser_id => 25170, :transaction_id => 385, :amount => 5.0},
            {:publiser_id => 25189, :transaction_id => 388, :amount => 10.0},
            {:publiser_id => 25189, :transaction_id => 389, :amount => 10.0},
            {:publiser_id => 25189, :transaction_id => 390, :amount => 10.0},
            {:publiser_id => 25189, :transaction_id => 391, :amount => 10.0},
            {:publiser_id => 25189, :transaction_id => 392, :amount => 10.0},
            {:publiser_id => 25189, :transaction_id => 393, :amount => 10.0},
            {:publiser_id => 25226, :transaction_id => 397, :amount => 5.0},
            {:publiser_id => 25331, :transaction_id => 417, :amount => 5.0},
            {:publiser_id => 25331, :transaction_id => 418, :amount => 5.0},
            {:publiser_id => 25447, :transaction_id => 431, :amount => 5.0},
            {:publiser_id => 25447, :transaction_id => 432, :amount => 5.0},
            {:publiser_id => 25447, :transaction_id => 433, :amount => 5.0},
            {:publiser_id => 25447, :transaction_id => 434, :amount => 5.0},
            {:publiser_id => 25447, :transaction_id => 435, :amount => 5.0},
            {:publiser_id => 25537, :transaction_id => 446, :amount => 5.0},
            {:publiser_id => 25613, :transaction_id => 456, :amount => 5.0},
            {:publiser_id => 25613, :transaction_id => 457, :amount => 5.0},
            {:publiser_id => 25812, :transaction_id => 493, :amount => 5.0},
            {:publiser_id => 25826, :transaction_id => 498, :amount => 10.0},
            {:publiser_id => 25878, :transaction_id => 508, :amount => 5.0},
            {:publiser_id => 25959, :transaction_id => 521, :amount => 10.0},
            {:publiser_id => 25990, :transaction_id => 526, :amount => 5.0},
            {:publiser_id => 26017, :transaction_id => 530, :amount => 5.0},
            {:publiser_id => 26186, :transaction_id => 539, :amount => 5.0},
            {:publiser_id => 26226, :transaction_id => 547, :amount => 5.0},
            {:publiser_id => 26226, :transaction_id => 548, :amount => 5.0},
            {:publiser_id => 26236, :transaction_id => 552, :amount => 5.0},
            {:publiser_id => 26411, :transaction_id => 574, :amount => 5.0},
            {:publiser_id => 26411, :transaction_id => 575, :amount => 5.0},
            {:publiser_id => 26562, :transaction_id => 598, :amount => 5.0},
            {:publiser_id => 26562, :transaction_id => 599, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 603, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 604, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 605, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 606, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 607, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 608, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 609, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 610, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 611, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 612, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 613, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 614, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 615, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 616, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 617, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 618, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 619, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 620, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 621, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 622, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 623, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 624, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 625, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 626, :amount => 5.0},
            {:publiser_id => 26612, :transaction_id => 628, :amount => 5.0},
            {:publiser_id => 26617, :transaction_id => 841, :amount => 5.0},
            {:publiser_id => 27001, :transaction_id => 754, :amount => 5.0},
            {:publiser_id => 27001, :transaction_id => 755, :amount => 5.0},
            {:publiser_id => 27001, :transaction_id => 756, :amount => 5.0},
            {:publiser_id => 27001, :transaction_id => 762, :amount => 5.0},
            {:publiser_id => 27001, :transaction_id => 772, :amount => 5.0},
            {:publiser_id => 27001, :transaction_id => 773, :amount => 5.0},
            {:publiser_id => 27001, :transaction_id => 775, :amount => 5.0},
            {:publiser_id => 27001, :transaction_id => 780, :amount => 5.0},
            {:publiser_id => 27001, :transaction_id => 781, :amount => 5.0},
            {:publiser_id => 27001, :transaction_id => 782, :amount => 5.0},
            {:publiser_id => 27001, :transaction_id => 785, :amount => 5.0},
            {:publiser_id => 27020, :transaction_id => 752, :amount => 10.0},
            {:publiser_id => 27020, :transaction_id => 758, :amount => 10.0},
            {:publiser_id => 27020, :transaction_id => 759, :amount => 10.0},
            {:publiser_id => 27020, :transaction_id => 760, :amount => 10.0}]
  
    data.each do |d| 
      CleanCoupon.remove_coupon(d[:publiser_id], d[:transaction_id], d[:amount]) 
    end
  end
  
  def self.down
  end
end
