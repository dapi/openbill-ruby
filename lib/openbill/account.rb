module Openbill
  class Account < Sequel::Model(ACCOUNTS_TABLE_NAME)
    def amount
      Money.new amount_cents, amount_currency
    end
  end
end
