require 'date'

# В.1 Метод calc до перейменування (Rename Method)

module RenameMethodBefore
  class Loan
    DAILY_RATE = 5

    def initialize(due_on, returned_on)
      @due_on = due_on
      @returned_on = returned_on
    end

    def calc
      days = (@returned_on - @due_on).to_i
      days.positive? ? days * DAILY_RATE : 0
    end
  end
end

# В.2 Метод overdue_fine після перейменування (Rename Method)

module RenameMethodAfter
  class Loan
    DAILY_RATE = 5

    def initialize(due_on, returned_on)
      @due_on = due_on
      @returned_on = returned_on
    end

    def overdue_fine
      days = (@returned_on - @due_on).to_i
      days.positive? ? days * DAILY_RATE : 0
    end

    # @deprecated Use {#overdue_fine} instead.
    def calc
      warn 'calc is deprecated, use overdue_fine',
           uplevel: 1
      overdue_fine
    end
  end
end

# В.3 Метод overdue_fine до видалення параметра (Remove Parameter)

module RemoveParameterBefore
  class Loan
    def initialize(due_on, returned_on)
      @due_on = due_on
      @returned_on = returned_on
    end

    def overdue_fine(daily_rate, currency)
      overdue_days * daily_rate
    end

    private

    def overdue_days
      [(@returned_on - @due_on).to_i, 0].max
    end
  end
end

# В.4 Метод overdue_fine після видалення параметра (Remove Parameter)

module RemoveParameterAfter
  class Loan
    def initialize(due_on, returned_on)
      @due_on = due_on
      @returned_on = returned_on
    end

    def overdue_fine(daily_rate)
      overdue_days * daily_rate
    end

    private

    def overdue_days
      [(@returned_on - @due_on).to_i, 0].max
    end
  end
end

# В.5 Метод overdue_fine до додавання параметра (Add Parameter)

module AddParameterBefore
  class Loan
    def initialize(due_on, returned_on)
      @due_on = due_on
      @returned_on = returned_on
    end

    def overdue_fine(daily_rate)
      overdue_days * daily_rate
    end

    private

    def overdue_days
      [(@returned_on - @due_on).to_i, 0].max
    end
  end
end

# В.6 Метод overdue_fine після додавання параметра (Add Parameter)

module AddParameterAfter
  class Loan
    def initialize(due_on, returned_on)
      @due_on = due_on
      @returned_on = returned_on
    end

    def overdue_fine(daily_rate, grace_days: 0)
      [overdue_days - grace_days, 0].max * daily_rate
    end

    private

    def overdue_days
      [(@returned_on - @due_on).to_i, 0].max
    end
  end
end

# В.7 Клас Loan після застосування трьох методів

module Library
  # Book loan with the overdue fine calculation.
  class Loan
    attr_reader :due_on, :returned_on

    def initialize(due_on, returned_on)
      @due_on = due_on
      @returned_on = returned_on
    end

    # Calculates the fine for a late return.
    #
    # @param daily_rate [Integer] fine for one overdue day
    # @param grace_days [Integer] days without a fine
    # @return [Integer] fine amount
    # @example
    #   loan.overdue_fine(5, grace_days: 2) #=> 10
    def overdue_fine(daily_rate, grace_days: 0)
      [overdue_days - grace_days, 0].max * daily_rate
    end

    # @deprecated Use {#overdue_fine} instead.
    def calc(daily_rate, _currency = nil)
      warn 'calc is deprecated, use overdue_fine',
           uplevel: 1
      overdue_fine(daily_rate)
    end

    private

    def overdue_days
      [(returned_on - due_on).to_i, 0].max
    end
  end
end

# В.8 Модульні тести RSpec

if defined?(RSpec)
  RSpec.describe Library::Loan do
    subject(:loan) { described_class.new(Date.new(2026, 11, 1), Date.new(2026, 11, 5)) }

    describe '#overdue_fine' do
      it 'charges the daily rate for each overdue day' do
        expect(loan.overdue_fine(5)).to eq(20)
      end

      it 'skips grace days' do
        fine = loan.overdue_fine(5, grace_days: 2)
        expect(fine).to eq(10)
      end

      it 'returns zero for a return before the due date' do
        early = described_class.new(Date.new(2026, 11, 5), Date.new(2026, 11, 1))
        expect(early.overdue_fine(5)).to eq(0)
      end
    end

    describe '#calc' do
      it 'returns the same result as the new method' do
        expect { expect(loan.calc(5, 'UAH')).to eq(loan.overdue_fine(5)) }
          .to output(/deprecated/).to_stderr
      end
    end
  end
end

# В.9 Перевірка збереження поведінки

module Compare
  def self.random_loan(random)
    due_on = Date.new(2026, 1, 1) + random.rand(0..300)
    [due_on, due_on + random.rand(-10..30)]
  end

  def self.same_result?(due_on, returned_on)
    rate = RenameMethodBefore::Loan::DAILY_RATE
    [
      RenameMethodBefore::Loan.new(due_on, returned_on).calc,
      RenameMethodAfter::Loan.new(due_on, returned_on).overdue_fine,
      RemoveParameterBefore::Loan.new(due_on, returned_on).overdue_fine(rate, 'UAH'),
      RemoveParameterAfter::Loan.new(due_on, returned_on).overdue_fine(rate),
      AddParameterBefore::Loan.new(due_on, returned_on).overdue_fine(rate),
      AddParameterAfter::Loan.new(due_on, returned_on).overdue_fine(rate)
    ].uniq.size == 1
  end

  def self.run
    random = Random.new(42)
    loans = Array.new(10_000) { random_loan(random) }
    day = Date.new(2026, 11, 1)
    loans += [[day, day], [day, day - 1], [day, day + 1]]
    mismatches = loans.reject { |due_on, returned_on| same_result?(due_on, returned_on) }

    puts "Checked loans: #{loans.size}"
    puts "Mismatches: #{mismatches.size}"
  end
end

Compare.run if $PROGRAM_NAME == __FILE__
