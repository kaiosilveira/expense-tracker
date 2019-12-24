require "minitest/autorun"
require "date"
require_relative "./index.rb"
require_relative "../transaction/index.rb"
require_relative "../period/index.rb"
require_relative "../../builders/transaction/index.rb"

describe DebitWallet do
  describe "initialize" do
    it "should instantiate transactions as an empty array as default" do
      id = 1
      name = "Carteira"
      initialAmount = 100.00
      wallet = DebitWallet.new(id, name, initialAmount)

      assert_equal(id, wallet.id)
      assert_equal(name, wallet.name)
      assert_equal(initialAmount, wallet.initialAmount)
      assert_equal([], wallet.transactions)
    end

    it "should instantiate a full instance" do
      id = 1
      name = "Carteira"
      initialAmount = 100.00
      transactions = []
      wallet = DebitWallet.new(id, name, initialAmount, transactions)

      assert_equal(id, wallet.id)
      assert_equal(name, wallet.name)
      assert_equal(initialAmount, wallet.initialAmount)
      assert_equal(transactions, wallet.transactions)
    end
  end

  describe "get_revenue" do
    it "should sum up the total revenue of the wallet if no filters were passed in" do
      initialAmount = 50

      transaction1 = Transaction.new
      transaction1.amount = 50
      transaction1.paid = true
      transaction1.type = "revenue"

      transaction2 = Transaction.new
      transaction2.amount = 50
      transaction2.paid = true
      transaction2.type = "revenue"

      transactions = [transaction1, transaction2]
      wallet = DebitWallet.new(1, "My Wallet", initialAmount, transactions)
      assert_equal transactions.select { |t|
                     t.paid == true && t.type = "revenue"
                   }.inject(0) { |sum, t|
                     sum + t.amount
                   } + initialAmount, wallet.get_revenue
    end

    it "should sum up the total revenue of a given month" do
      walletCreationDate = DateTime.new(2019, 12, 1)

      month = 12
      year = 2019

      transaction1 = TransactionBuilder.new
        .paid(true)
        .withAmount(50.00)
        .withDate(DateTime.new(2019, 12, 1))
        .withType("revenue")
        .build

      transaction2 = TransactionBuilder.new
        .paid(true)
        .withAmount(50.00)
        .withDate(DateTime.new(2019, 12, 3))
        .withType("revenue")
        .build

      transaction3 = TransactionBuilder.new
        .paid(true)
        .withAmount(50.00)
        .withDate(DateTime.new(2019, 11, 1))
        .withType("revenue")
        .build

      transactions = [transaction1, transaction2, transaction3]
      wallet = DebitWallet.new(1, "My Wallet", 0.0, transactions, walletCreationDate)
      assert_equal(
        (transaction1.amount + transaction2.amount),
        wallet.get_revenue(Period.new(month, year))
      )
    end

    it "should sum up the total revenue of a given range" do
      initialAmount = 30.0
      walletCreationDate = DateTime.new(2019, 11, 1)

      from = Period.new(11, 2019)
      to = Period.new(12, 2019)

      transaction1 = TransactionBuilder.new
        .paid(true)
        .withAmount(50.00)
        .withDate(DateTime.new(2019, 12, 1))
        .withType("revenue")
        .build

      transaction2 = TransactionBuilder.new
        .paid(true)
        .withAmount(50.00)
        .withDate(DateTime.new(2019, 12, 3))
        .withType("revenue")
        .build

      transaction3 = TransactionBuilder.new
        .paid(true)
        .withAmount(50.00)
        .withDate(DateTime.new(2019, 11, 1))
        .withType("revenue")
        .build

      transaction4 = TransactionBuilder.new
        .paid(true)
        .withAmount(50.00)
        .withDate(DateTime.new(2019, 10, 1))
        .withType("revenue")
        .build

      transactions = [transaction1, transaction2, transaction3, transaction4]
      wallet = DebitWallet.new(1, "My Wallet", initialAmount, transactions, walletCreationDate)

      assert_equal(
        (initialAmount + transaction1.amount + transaction2.amount + transaction3.amount),
        wallet.get_revenue([from, to])
      )
    end

    it "should apply wallet initialAmount in the sum just if wallet creation date is at the given period" do
      initialAmount = 30.0
      period = Period.new(10, 2019)
      wallet1CreationDate = DateTime.new(2019, 9)
      wallet2CreationDate = DateTime.new(period.year, period.month)

      transaction1 = TransactionBuilder.new
        .paid(true)
        .withAmount(10.0)
        .withType("revenue")
        .withDate(DateTime.new(period.year, period.month))
        .build()

      transaction2 = TransactionBuilder.new
        .paid(true)
        .withAmount(10.0)
        .withType("revenue")
        .withDate(DateTime.new(period.year, period.month))
        .build()

      transactions = [transaction1, transaction2]

      wallet1 = DebitWallet.new(nil, "My Wallet", initialAmount, transactions, wallet1CreationDate)
      wallet2 = DebitWallet.new(nil, "My Wallet", initialAmount, transactions, wallet2CreationDate)

      assert_equal(
        (transaction1.amount + transaction2.amount), wallet1.get_revenue(period)
      )
      assert_equal(
        (initialAmount + transaction1.amount + transaction2.amount),
        wallet2.get_revenue(period)
      )
    end

    it "should apply wallet initialAmount in the sum just if wallet creation date is inside the given range" do
      initialAmount = 30.0
      wallet1CreationDate = DateTime.new(2019, 9)
      wallet2CreationDate = DateTime.new(2019, 10)

      from = Period.new(10, 2019)
      to = Period.new(11, 2019)

      transaction1 = TransactionBuilder.new
        .paid(true)
        .withAmount(10.0)
        .withType("revenue")
        .withDate(DateTime.new(2019, 11))
        .build()

      transaction2 = TransactionBuilder.new
        .paid(true)
        .withAmount(10.0)
        .withType("revenue")
        .withDate(DateTime.new(2019, 10))
        .build()

      transactions = [transaction1, transaction2]

      wallet1 = DebitWallet.new(nil, "My Wallet", initialAmount, transactions, wallet1CreationDate)
      wallet2 = DebitWallet.new(nil, "My Wallet", initialAmount, transactions, wallet2CreationDate)

      assert_equal(
        (transaction1.amount + transaction2.amount),
        wallet1.get_revenue([from, to])
      )
      assert_equal(
        (initialAmount + transaction1.amount + transaction2.amount),
        wallet2.get_revenue([from, to])
      )
    end
  end

  describe "get_expenses" do
    it "should sum up all expenses if no filter was passed in" do
      transaction1 = Transaction.new
      transaction1.amount = 50
      transaction1.paid = true
      transaction1.type = "expense"

      transaction2 = Transaction.new
      transaction2.amount = 50
      transaction2.paid = true
      transaction2.type = "expense"

      transactions = [transaction1, transaction2]

      wallet = DebitWallet.new(1, "My Wallet", 0, transactions)

      assert_equal (-1) * transactions.select { |t|
                     t.paid == true && t.type = "expense"
                   }.inject(0) { |sum, t|
                     sum + t.amount
                   }, wallet.get_expenses
    end

    it "should sum up the total of expenses for a given month" do
      walletCreationDate = DateTime.new(2019, 12, 1)

      month = 12
      year = 2019

      transaction1 = TransactionBuilder.new
        .paid(true)
        .withAmount(50.00)
        .withDate(DateTime.new(2019, 12, 1))
        .withType("expense")
        .build

      transaction2 = TransactionBuilder.new
        .paid(true)
        .withAmount(50.00)
        .withDate(DateTime.new(2019, 12, 3))
        .withType("expense")
        .build

      transaction3 = TransactionBuilder.new
        .paid(true)
        .withAmount(50.00)
        .withDate(DateTime.new(2019, 11, 1))
        .withType("expense")
        .build

      transactions = [transaction1, transaction2, transaction3]
      wallet = DebitWallet.new(1, "My Wallet", 0.0, transactions, walletCreationDate)
      assert_equal(
        (transaction1.amount + transaction2.amount) * -1,
        wallet.get_expenses(Period.new(month, year))
      )
    end

    it "should sum up the total of expenses for a given range" do
      walletCreationDate = DateTime.new(2019, 11, 1)

      from = Period.new(11, 2019)
      to = Period.new(12, 2019)

      transaction1 = TransactionBuilder.new
        .paid(true)
        .withAmount(50.00)
        .withDate(DateTime.new(2019, 12, 1))
        .withType("expense")
        .build

      transaction2 = TransactionBuilder.new
        .paid(true)
        .withAmount(50.00)
        .withDate(DateTime.new(2019, 12, 3))
        .withType("expense")
        .build

      transaction3 = TransactionBuilder.new
        .paid(true)
        .withAmount(50.00)
        .withDate(DateTime.new(2019, 11, 1))
        .withType("expense")
        .build

      transaction4 = TransactionBuilder.new
        .paid(true)
        .withAmount(50.00)
        .withDate(DateTime.new(2019, 10, 1))
        .withType("expense")
        .build

      transactions = [transaction1, transaction2, transaction3, transaction4]
      wallet = DebitWallet.new(1, "My Wallet", 0.0, transactions, walletCreationDate)

      assert_equal(
        (transaction1.amount + transaction2.amount + transaction3.amount) * -1,
        wallet.get_expenses([from, to])
      )
    end
  end

  describe "get_balance" do
    it "should get the current wallet balance" do
      initialAmount = 50.0

      expense1 = Transaction.new
      expense1.amount = 100.0
      expense1.paid = true
      expense1.type = "expense"

      expense2 = Transaction.new
      expense2.amount = 50.0
      expense2.paid = true
      expense2.type = "expense"

      revenue = Transaction.new
      revenue.amount = 100.0
      revenue.paid = true
      revenue.type = "revenue"

      transactions = [expense1, expense2, revenue]

      wallet = DebitWallet.new(1, "My Wallet", initialAmount, transactions)

      assert_equal initialAmount + revenue.amount - expense1.amount - expense2.amount, wallet.get_balance
    end
  end

  describe "add_transaction" do
    it "should add a transaction to the wallet" do
      wallet = DebitWallet.new(nil, "My Wallet")
      transaction = TransactionBuilder.new.paid(true).withAmount(10.0).build()
      wallet.add_transaction(transaction)
      assert_equal(wallet.transactions.length, 1)
    end
  end
end
