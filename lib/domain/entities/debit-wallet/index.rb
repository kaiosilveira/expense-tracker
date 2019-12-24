require "date"
require_relative "../period/index.rb"

class DebitWallet
  attr_reader :id
  attr_reader :name
  attr_reader :initialAmount
  attr_reader :transactions
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
    return revenue_sum + @initialAmount if filters.nil? || period_contains?(@createdAt, filters)
    return revenue_sum
  end

  def get_expenses(filters = nil)
    return -1 * sum_transactions(filter_transactions_by("expense", filters))
  end

  def get_balance
    self.get_revenue + self.get_expenses
  end

  def add_transaction(transaction)
    @transactions << transaction
  end

  private

  def date_is_inside_period?(date, period)
    date.month == period.month && date.year == period.year
  end

  def date_is_inside_period_range?(date, range)
    from, to = range
    return from.month <= date.month && date.month <= to.month &&
             from.year <= date.year && date.year <= to.year
  end

  def period_contains?(date, range)
    range.respond_to?("each") ? date_is_inside_period_range?(date, range) : date_is_inside_period?(date, range)
  end

  def sum_transactions(transactions)
    transactions.inject(0) { |sum, t|
      sum + t.amount
    }
  end

  def filter_transactions_by(type, range = nil)
    @transactions.select { |t|
      t.paid == true && t.type == type && (range.nil? || period_contains?(t.date, range))
    }
  end
end
