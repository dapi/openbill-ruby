module Openbill
  class Transaction < Sequel::Model(TRANSACTIONS_TABLE_NAME)
    def amount
      Money.new amount_cents, amount_currency
    end
  end
end
