require 'date'

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

  def get_revenue
    @transactions.select { |t|
      t.paid == true && t.type == "revenue"
    }.inject(0) { |sum, t|
      sum + t.amount
    } + @initialAmount
  end

  def get_expenses
    -1 * @transactions.select { |t|
      t.paid == true && t.type == "expense"
    }.inject(0) { |sum, t|
      sum + t.amount
    }
  end

  def get_balance
    self.get_revenue + self.get_expenses
  end
end
