require_relative "../../entities/transaction/index.rb"

class TransactionBuilder
  :transaction

  def initialize
    @transaction = Transaction.new
    @transaction.amount = 0.0
    @transaction.currency = "BRL"
    @transaction.description = "others"
    @transaction.date = DateTime.new
    @transaction.paid = false
    @transaction.category = "others"
  end

  def build
    @transaction
  end

  def withAmount(v)
    @transaction.amount = v
    self
  end

  def withCurrency(c)
    @transaction.currency = c
    self
  end

  def withDescription(d)
    @transaction.description = d
    self
  end

  def withDate(d)
    @transaction.date = d
    self
  end

  def paid(p)
    @transaction.paid = p
    self
  end

  def withWalletId(id)
    @transaction.walletId = id
    self
  end

  def withCategory(c)
    @transaction.category = c
    self
  end

  def withType(t)
    @transaction.type = t
    self
  end
end