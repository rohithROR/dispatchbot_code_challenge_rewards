require 'time'
require 'date'
require_relative 'rewards_calculator'

class Order

    include RewardsCalculator

    attr_accessor :amount, :created_at

    def initialize(amount, created_at)
        @amount = amount
        @created_at = begin
                         Time.xmlschema(created_at) 
                      rescue
                          DateTime.strptime(created_at, '%FT%T%:z') 
                      end 
    end

    def rewards
        @rewards ||= _calculate_reward
    end

    protected

    def _calculate_reward
        fetch_reward_points(self.amount, self.created_at)
    end
    
end