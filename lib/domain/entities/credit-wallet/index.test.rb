require "minitest/autorun"
require_relative "./index.rb"
require_relative "../../builders/transaction/index.rb"
require_relative "../debit-wallet/index.rb"

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
      msg = "Credit transactions cannot be already paid."
      error = assert_raises(Exception) {
        wallet.add_transaction(transaction)
      }

      assert_equal(error.message, msg)
    end

    it "should raise an exception if transation if fixed" do
      transaction = TransactionBuilder.new.isFixed(true).withAmount(10.0).build()
      wallet = CreditWallet.new(id = nil, name = "My Wallet", limit = 1000.0)
      msg = "Credit transactions cannot be fixed."
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

    it "should sum only the unpaid transactions" do
      transaction1 = TransactionBuilder.new.withAmount(100.00).build()
      transaction2 = TransactionBuilder.new.paid(true).withAmount(100.00).build()
      transactions = [transaction1, transaction2]
      wallet = CreditWallet.new(id = nil, name = "Credit Wallet", limit = 200.00, transactions)
      debit = wallet.get_total_debit()
      assert_equal(transaction1.amount, debit)
    end
  end

  describe "add_payment" do
    it "should process the payment and add an expense transaction into the debit wallet" do
      debit_wallet = DebitWallet.new(id = nil, name = "Debit Wallet", initial_amount = 100.0)
      credit_transactions = [TransactionBuilder.new.withAmount(100.0).build()]
      credit_wallet = CreditWallet.new(
        id = nil,
        name = "Credit Wallet",
        limit = 100.0,
        credit_transactions
      )

      fullPaymentAmount = credit_wallet.get_total_debit()
      credit_wallet.add_payment(fullPaymentAmount, debit_wallet)

      assert_equal(debit_wallet.transactions.length, 1)
      assert_equal(debit_wallet.transactions.first.amount, fullPaymentAmount)
      assert_equal(credit_wallet.get_total_debit(), 0)
    end

    it "should charge only the remaining debit if the given payment amount is greater than the remaining amount" do
      debit_wallet = DebitWallet.new(
        id = nil,
        name = "Debit Wallet",
        initial_amount = 100
      )

      transaction = TransactionBuilder.new.withAmount(75.00).withType("expense").build()
      transactions = [transaction]
      credit_wallet = CreditWallet.new(id = nil, name = "Credit Wallet", limit = 100.00, transactions)
      total_debit = credit_wallet.get_total_debit()

      credit_wallet.add_payment(total_debit, debit_wallet)

      assert_equal(debit_wallet.transactions.length, 1)
      assert_equal(total_debit, debit_wallet.transactions.first().amount)
      assert_equal(credit_wallet.get_total_debit(), 0)
      assert_equal(debit_wallet.initial_amount - total_debit, debit_wallet.get_balance())
    end
  end
end
