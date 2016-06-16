module Openbill
  class Transaction < Sequel::Model(TRANSACTIONS_TABLE_NAME)
    many_to_one :from_account, class: 'Openbill::Account'
    many_to_one :to_account, class: 'Openbill::Account'
    many_to_one :good, class: 'Openbill::Good'

    def amount
      Money.new amount_cents, amount_currency
    end
  end
end
