require "minitest/autorun"
require_relative "../../builders/transaction/index.rb"
require_relative "../debit-wallet/index.rb"

# a credit wallet has a limit - ok
# a credit wallet only accepts unpaid transactions - ok
# a credit wallet have to be paid with a debit wallet
# a credit wallet may accept partial payments
# a credit wallet does not accept fixed payments

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
    raise "Credit transactions cannot be already paid" if transaction.paid
    @transactions << transaction
  end

  def get_total_debit
    @transactions.inject(0) { |sum, t| sum + t.amount }
  end

  def add_payment!(amount, wallet)
    transaction = TransactionBuilder.new.withAmount(amount).build()
    wallet.add_transaction(transaction)
    @transactions.each { |t|
      t.paid = true
    }
  end
end

describe CreditWallet do
  describe "initialize" do
    it "should apply id as nil by default" do
      assert_nil(CreditWallet.new.id)
    end

    it "should apply name as empty string by default" do
      assert_equal(CreditWallet.new.name, "")
    end

    it "should apply limit as zero by default" do
      assert_equal(CreditWallet.new.limit, 0.0)
    end

    it "should has transactions as an empty array by default" do
      assert_equal(CreditWallet.new.transactions, [])
    end

    it "should apply id to the class" do
      id = 1
      assert_equal(CreditWallet.new(id).id, id)
    end

    it "should apply name to the class" do
      name = "My Wallet"
      assert_equal(CreditWallet.new(id = nil, name).name, name)
    end

    it "should apply limit to the class" do
      limit = 1000.0
      assert_equal(CreditWallet.new(id = nil, name = "", limit).limit, limit)
    end

    it "should apply transactions to the class" do
      transaction = TransactionBuilder.new.withAmount(100).build()
      transactions = [transaction]
      wallet = CreditWallet.new(id = nil, name = "", limit = 1000.0, transactions)

      assert_equal(wallet.transactions, transactions)
    end

    it "should build a full qualified instance" do
      id = 1
      name = "My Wallet"
      limit = 1000.0
      wallet = CreditWallet.new(id, name, limit)

      assert_equal(wallet.id, id)
      assert_equal(wallet.name, name)
      assert_equal(wallet.limit, limit)
    end
  end

  describe "add_transaction" do
    it "should raise an exception if transaction is paid" do
      transaction = TransactionBuilder.new.paid(true).withAmount(10.0).build()
      wallet = CreditWallet.new(id = nil, name = "My Wallet", limit = 1000.0)
      msg = "Credit transactions cannot be already paid"
      error = assert_raises(Exception) {
        wallet.add_transaction(transaction)
      }

      assert_equal(error.message, msg)
    end

    it "should add a transaction" do
      transaction = TransactionBuilder.new.withAmount(10.0).build()
      wallet = CreditWallet.new(id = nil, name = "My Wallet", limit = 1000.0)
      wallet.add_transaction(transaction)
      assert_equal(wallet.transactions.length, 1)
    end
  end

  describe "get_total_debit" do
    it "should get the total debit of the wallet" do
      transaction = TransactionBuilder.new.withAmount(100.0).build()
      transactions = [transaction]
      wallet = CreditWallet.new(id = nil, name = "Credit Wallet", limit = 1000.0, transactions)
      debit = wallet.get_total_debit()
      assert_equal(debit, transaction.amount)
    end
  end

  describe "add_payment" do
    it "should process the payment and add an expense transaction into the debit wallet" do
      debit_wallet = DebitWallet.new(id = nil, name = "Debit Wallet", initialAmount = 100.0)
      credit_transactions = [TransactionBuilder.new.withAmount(100.0).build()]
      credit_wallet = CreditWallet.new(
        id = nil,
        name = "Credit Wallet",
        limit = 100.0,
        credit_transactions
      )

      paymentAmount = credit_wallet.get_total_debit()
      credit_wallet.add_payment!(paymentAmount, debit_wallet)
    end
  end
end
