module Openbill
  class Invoice < Sequel::Model(INVOICES_TABLE_NAME)
    many_to_one :destination_account, class: 'Openbill::Account'

    def amount
      Money.new amount_cents, amount_currency
    end
  end
end
