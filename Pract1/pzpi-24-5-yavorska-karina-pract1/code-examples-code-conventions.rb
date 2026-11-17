# В.1 Приклад оформлення програмного коду

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

# В.2 Приклад програмного коду до рефакторингу

module Before
  def self.CalcPrice(u,items)
      if u!=nil
          t=0
          for i in items do t+=i.price end
          if u.is_vip then t=t*0.8 end
          return t
      end
  end
end

# В.3 Приклад програмного коду після рефакторингу

module After
  VIP_DISCOUNT = 0.8

  def self.total_price(user, items)
    return unless user

    total = items.sum(&:price)
    user.vip? ? total * VIP_DISCOUNT : total
  end
end

# В.4.1 Порядок частин класу

module MyGem
  # Library user (file lib/my_gem/user.rb).
  class User
    include Comparable

    MAX_AGE = 150

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def <=>(other)
      name <=> other.name
    end

    private

    def normalized_name
      name.strip.downcase
    end
  end
end

# В.4.2 Форматування коду

module Formatting
  TAX = 5

  # Bad: 4-space indent, no spaces around operators, explicit return.
  def self.total_bad(price,qty)
      sum=price*qty+TAX
      return sum
  end

  # Good.
  def self.total(price, qty)
    price * qty + TAX
  end

  def self.print_names(names)
    names.each { |n| puts n }
  end

  def self.upcase_names(names)
    names.map do |n|
      n.upcase
    end
  end
end

# В.4.3 Коментарі та анотації

module Comments
  def self.next_counter(counter)
    counter += 1 # increment counter
  end

  def self.prepare(response)
    # API returns a frozen object,
    # so dup it before changing.
    data = response.dup
    # FIXME: Crashes since v3.2.1.
    data << 'checked'
  end
end

# В.4.4 Документування методу за допомогою YARD

module Pricing
  # Calculates the price after a discount.
  #
  # @param price [Numeric] base price
  # @param percent [Integer] 0..100
  # @return [Float] discounted price
  # @raise [ArgumentError] if percent > 100
  # @example
  #   discount(200, 10) #=> 180.0
  def self.discount(price, percent)
    raise ArgumentError if percent > 100

    price * (100 - percent) / 100.0
  end
end

# В.4.5 Модульний тест RSpec і реалізація

module FizzBuzz
  def self.call(n) = (n % 3).zero? ? 'Fizz' : n.to_s
end

if defined?(RSpec)
  RSpec.describe FizzBuzz do
    describe '.call' do
      it 'returns Fizz for 9' do
        expect(FizzBuzz.call(9)).to eq('Fizz')
      end
    end
  end
end

# В.4.6 Перевірка еквівалентності коду до і після рефакторингу

module Compare
  User = Struct.new(:vip) do
    def vip? = vip
    def is_vip = vip
  end

  Item = Struct.new(:price)

  def self.random_order(random)
    user = random.rand < 0.1 ? nil : User.new(random.rand < 0.5)
    items = Array.new(random.rand(0..5)) { Item.new(random.rand(1..900)) }
    [user, items]
  end

  def self.run
    random = Random.new(42)
    orders = Array.new(2000) { random_order(random) }
    orders += [[nil, []], [User.new(true), []], [User.new(false), [Item.new(1000)]]]
    mismatches = orders.reject do |user, items|
      Before.CalcPrice(user, items) == After.total_price(user, items)
    end

    puts "Checked orders: #{orders.size}"
    puts "Mismatches: #{mismatches.size}"
  end
end

Compare.run if $PROGRAM_NAME == __FILE__

# В.4.7 Налаштування RuboCop

# # .rubocop.yml
# AllCops:
#   TargetRubyVersion: 3.4
#   NewCops: enable
# Layout/LineLength:
#   Max: 120

# В.4.8 Git-хук для перевірки стилю перед комітом

# # lefthook.yml
# pre-commit:
#   commands:
#     rubocop:
#       run: bundle exec rubocop {staged_files}

# В.4.9 Конвеєр безперервної інтеграції

# # .github/workflows/ci.yml
# name: CI
#
# on: [push, pull_request]
#
# jobs:
#   check:
#     runs-on: ubuntu-latest
#     steps:
#       - uses: actions/checkout@v4
#       - uses: ruby/setup-ruby@v1
#         with:
#           bundler-cache: true
#       - run: bundle exec rubocop
#       - run: bundle exec rspec
