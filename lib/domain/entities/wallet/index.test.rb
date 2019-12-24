require "minitest/autorun"
require "date"
require_relative "./index.rb"
require_relative "../transaction/index.rb"
require_relative "../../builders/transaction/index.rb"

describe Wallet do
  describe "initialize" do
    it "should instantiate transactions as an empty array as default" do
      id = 1
      name = "Carteira"
      initialAmount = 100.00
      wallet = Wallet.new(id, name, initialAmount)
      _(wallet.id).must_equal id
      _(wallet.name).must_equal name
      _(wallet.initialAmount).must_equal initialAmount
      _(wallet.transactions).must_equal []
    end

    it "should instantiate a full instance" do
      id = 1
      name = "Carteira"
      initialAmount = 100.00
      transactions = []
      wallet = Wallet.new(id, name, initialAmount, transactions)
      _(wallet.id).must_equal id
      _(wallet.name).must_equal name
      _(wallet.initialAmount).must_equal initialAmount
      _(wallet.transactions).must_equal transactions
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
      wallet = Wallet.new(1, "My Wallet", initialAmount, transactions)
      assert_equal transactions.select { |t|
                     t.paid == true && t.type = "revenue"
                   }.inject(0) { |sum, t|
                     sum + t.amount
                   } + initialAmount, wallet.get_revenue
    end

    it "should sum up the total revenue of a given month" do
      initialAmount = 30.0
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
      wallet = Wallet.new(1, "My Wallet", initialAmount, transactions)
      assert_equal (initialAmount + transaction1.amount + transaction2.amount), wallet.get_revenue(TransactionPeriod.new(month, year))
    end

    it "should sum up the total revenue of a given range" do
      initialAmount = 30.0

      from = TransactionPeriod.new(11, 2019)
      to = TransactionPeriod.new(12, 2019)

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
      wallet = Wallet.new(1, "My Wallet", initialAmount, transactions)

      assert_equal (initialAmount + transaction1.amount + transaction2.amount + transaction3.amount), wallet.get_revenue([from, to])
    end
  end

  describe "get_expenses" do
    it "should sum up all expenses" do
      transaction1 = Transaction.new
      transaction1.amount = 50
      transaction1.paid = true
      transaction1.type = "expense"

      transaction2 = Transaction.new
      transaction2.amount = 50
      transaction2.paid = true
      transaction2.type = "expense"

      transactions = [transaction1, transaction2]

      wallet = Wallet.new(1, "My Wallet", 0, transactions)

      assert_equal (-1) * transactions.select { |t|
                     t.paid == true && t.type = "expense"
                   }.inject(0) { |sum, t|
                     sum + t.amount
                   }, wallet.get_expenses
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

      wallet = Wallet.new(1, "My Wallet", initialAmount, transactions)

      assert_equal initialAmount + revenue.amount - expense1.amount - expense2.amount, wallet.get_balance
    end
  end
end
