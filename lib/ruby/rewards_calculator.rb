module RewardsCalculator

   def fetch_reward_points(amount, created_at)
      reward_points = (rewards_multiplier(created_at) * amount).round
      (3..20) === reward_points ? reward_points : 0
   end

   private

   def rewards_multiplier(transaction_time)
      _time_float_value = (transaction_time.hour + transaction_time.min/100.0)
      case _time_float_value
        when (10..11)
          1
        when (11..12)
          (1/2)
        when (12..13)
          (1/3)
        when (13..14)
          (1/2)
        when (14..15)
          1
        else
          (1/4)
      end 
   end
end