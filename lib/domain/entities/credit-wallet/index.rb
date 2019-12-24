class CreditWallet
  attr_reader :id
  attr_reader :name
  attr_reader :limit
  attr_reader :transactions

  def initialize(id = nil, name = "", limit = 0.0, transactions = [])
    @id = id
    @name = name
    @limit = limit
    @transactions = transactions
  end

  def add_transaction(transaction)
    raise "Credit transactions cannot be already paid." if transaction.paid
    raise "Credit transactions cannot be fixed." if transaction.isFixed
    @transactions << transaction
  end

  def get_total_debit
    @transactions.select() { |t| t.paid == false }.inject(0) { |sum, t| sum + t.amount }
  end

  def add_payment(amount, wallet)
    total_debit = self.get_total_debit()
    transaction_amount = 0

    if (amount > total_debit)
      transaction_amount = total_debit
    else
      transaction_amount = amount
    end

    transaction = TransactionBuilder.new
      .paid(true)
      .withAmount(transaction_amount)
      .withType("expense")
      .build()

    wallet.add_transaction(transaction)
    @transactions.each { |t|
      t.paid = true
    }
  end
end
