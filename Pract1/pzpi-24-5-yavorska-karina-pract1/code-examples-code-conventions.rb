module Shop
  # Calculates order totals for registered users.
  class OrderCalculator
    include Comparable

    VIP_DISCOUNT = 0.8
    MAX_ITEMS = 100

    attr_reader :user, :items

    def initialize(user, items)
      @user = user
      @items = items
    end

    # Calculates the order total with the VIP discount applied.
    #
    # @return [Float, nil] order total, or nil if there is no user
    # @raise [ArgumentError] if the order has too many items
    # @example
    #   OrderCalculator.new(user, items).total_price #=> 120.0
    def total_price
      return unless user
      raise ArgumentError, 'Too many items' if items.size > MAX_ITEMS

      total = items.sum(&:price)
      user.vip? ? total * VIP_DISCOUNT : total
    end

    def empty?
      items.empty?
    end

    def <=>(other)
      total_price <=> other.total_price
    end

    private

    def item_names
      items.map(&:name)
    end
  end
end
