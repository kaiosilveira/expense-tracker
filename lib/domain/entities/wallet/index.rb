require "date"

class TransactionPeriod
  attr_reader :month
  attr_reader :year

  def initialize(month, year)
    @month = month
    @year = year
  end
end

class Wallet
  attr_accessor :id
  attr_accessor :name
  attr_accessor :initialAmount
  attr_accessor :transactions
  attr_reader :createdAt

  def initialize(id, name, initialAmount = 0, transactions = [])
    @id = id
    @name = name
    @createdAt = DateTime.now
    @initialAmount = initialAmount
    @transactions = transactions
  end

  def get_revenue(filters = nil)
    @initialAmount + sum_transactions_by("revenue", filters)
  end

  def get_expenses
    -1 * sum_transactions_by("expense")
  end

  def get_balance
    self.get_revenue + self.get_expenses
  end

  private

  def sum_transactions_by(type, range = nil)
    if (range == nil)
      return @transactions.select { |t|
               t.paid == true && t.type == type
             }.inject(0) { |sum, t|
               sum + t.amount
             }
    elsif (range.respond_to? "each")
      from, to = range
      return @transactions.select { |t|
               t.paid == true &&
                 t.type == type &&
                 from.month <= t.date.month && t.date.month <= to.month &&
                 from.year <= t.date.year && t.date.year <= to.year
             }.inject(0) { |sum, t|
               sum + t.amount
             }
    else
      @transactions.select { |t|
        t.paid == true && t.type == type && t.date.month == range.month && t.date.year == range.year
      }.inject(0) { |sum, t|
        sum + t.amount
      }
    end
  end
end
