require_relative "./lib/domain/entities/debit-wallet/index.rb"
require_relative "./lib/domain/builders/transaction/index.rb"

wallet = Wallet.new(1, "Physical Wallet", 100.0)

puts "Wallet ##{wallet.id} has a total of #{wallet.get_revenue} in revenue"
puts "Wallet ##{wallet.id} has a total of #{wallet.get_expenses} in expenses"

lunch = TransactionBuilder.new
  .paid(true)
  .withAmount(20.0)
  .withType("expense")
  .withDescription("Lunch with friends")
  .build()

puts "Lunch transaction added with a cost of #{lunch.amount} #{lunch.currency}"
wallet.transactions << lunch

puts "Wallet ##{wallet.id} has a total of #{wallet.get_revenue} in revenue"
puts "Wallet ##{wallet.id} has a total of #{wallet.get_expenses} in expenses"
puts "Wallet ##{wallet.id} has a remaining balance of #{wallet.get_balance}"

# TODO
# Installments
# Forecast
# Multicurrency
