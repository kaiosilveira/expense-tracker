require "date"
require_relative "../period/index.rb"

class Wallet
  attr_accessor :id
  attr_accessor :name
  attr_accessor :initialAmount
  attr_accessor :transactions
  attr_reader :createdAt

  def initialize(id, name, initialAmount = 0, transactions = [], createdAt = DateTime.now)
    @id = id
    @name = name
    @initialAmount = initialAmount
    @transactions = transactions
    @createdAt = createdAt
  end

  def get_revenue(filters = nil)
    revenue_sum = sum_transactions(filter_transactions_by("revenue", filters))
    if (filters.nil? || (!filters.respond_to?("each") && date_is_inside_period(@createdAt, filters)))
      return revenue_sum + @initialAmount
    elsif (filters.respond_to?("each"))
      inside_range = date_is_inside_period_range(@createdAt, filters)
      return inside_range ? revenue_sum + @initialAmount : revenue_sum
    else
      return revenue_sum
    end
  end

  def get_expenses
    -1 * sum_transactions(filter_transactions_by("expense"))
  end

  def get_balance
    self.get_revenue + self.get_expenses
  end

  private

  def date_is_inside_period(date, period)
    date.month == period.month && date.year == period.year
  end

  def date_is_inside_period_range(date, range)
    from, to = range
    return from.month <= date.month && date.month <= to.month &&
             from.year <= date.year && date.year <= to.year
  end

  def sum_transactions(transactions)
    transactions.inject(0) { |sum, t|
      sum + t.amount
    }
  end

  def filter_transactions_by(type, range = nil)
    if (range == nil)
      @transactions.select { |t|
        t.paid == true && t.type == type
      }
    elsif (range.respond_to? "each")
      @transactions.select { |t|
        t.paid == true && t.type == type && date_is_inside_period_range(t.date, range)
      }
    else
      @transactions.select { |t|
        t.paid == true && t.type == type && date_is_inside_period(t.date, range)
      }
    end
  end
end
