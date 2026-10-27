VIP_DISCOUNT = 0.8

def total_price(user, items)
  return unless user

  total = items.sum(&:price)
  user.vip? ? total * VIP_DISCOUNT : total
end
