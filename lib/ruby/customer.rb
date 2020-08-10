class Customer
    attr_accessor :name
    attr_reader   :orders 

    include Comparable

    def initialize(name)
        @name = name
        @orders = []
    end

    def add_order(order)
       @orders << Order.new(order["amount"], order["timestamp"])
    end

    def total_reward_points
        self.orders.sum{|order| order.rewards}
    end

    def ==(other)
        self.name == other.name
    end

    def total_orders_with_rewards
        self.orders.size{|order| order.total_reward_points > 0}
    end

    def average_points_per_order
        self.total_orders_with_rewards > 0 ? (self.total_reward_points/self.total_orders_with_rewards) : 0
    end

    def <=>(other)
        other.total_reward_points <=> self.total_reward_points
    end
end