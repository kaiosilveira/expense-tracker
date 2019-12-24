require "minitest/autorun"
require "date"
require_relative "./index.rb"
require_relative "../../entities/transaction/index.rb"

describe TransactionBuilder do
  it "should build a default transaction" do
    transaction = TransactionBuilder.new.build
    assert_equal 0.0, transaction.amount
    assert_equal "BRL", transaction.currency
    assert_equal "others", transaction.description
    assert_kind_of DateTime, transaction.date
    assert_equal false, transaction.paid
    assert_equal "others", transaction.category
  end

  it "should apply ammount" do
    amount = 50.0
    transaction = TransactionBuilder.new.withAmount(amount).build
    assert_equal transaction.amount, amount
  end

  it "should apply currency" do
    currency = "EUR"
    transaction = TransactionBuilder.new.withCurrency(currency).build
    assert_equal transaction.currency, currency
  end

  it "should apply description" do
    description = "Lunch"
    transaction = TransactionBuilder.new.withDescription(description).build
    assert_equal transaction.description, description
  end

  it "should apply date" do
    date = DateTime.now
    transaction = TransactionBuilder.new.withDate(date).build
    assert_equal transaction.date, date
  end

  it "should apply paid value" do
    paid = false
    transaction = TransactionBuilder.new.paid(paid).build
    assert_equal transaction.paid, paid
  end

  it "should apply wallet id" do
    walletId = 1
    transaction = TransactionBuilder.new.withWalletId(walletId).build
    assert_equal transaction.walletId, walletId
  end

  it "should apply transaction category" do
    category = "lunches"
    transaction = TransactionBuilder.new.withCategory(category).build
    assert_equal transaction.category, category
  end

  it "should apply transaction type" do
    type = "expense"
    transaction = TransactionBuilder.new.withType(type).build
    assert_equal transaction.type, type
  end

  it "should build a full instance" do
    amount = 50.0
    currency = "EUR"
    description = "Lunch"
    date = DateTime.now
    paid = true
    walletId = 1
    category = "Lunches"
    type = "expense"

    transaction = TransactionBuilder.new
      .withAmount(amount)
      .withCurrency(currency)
      .withDescription(description)
      .withDate(date)
      .paid(paid)
      .withWalletId(walletId)
      .withCategory(category)
      .withType(type)
      .build

    assert_equal transaction.amount, amount
    assert_equal transaction.currency, currency
    assert_equal transaction.description, description
    assert_equal transaction.date, date
    assert_equal transaction.paid, paid
    assert_equal transaction.walletId, walletId
    assert_equal transaction.category, category
    assert_equal transaction.type, type
  end
end
