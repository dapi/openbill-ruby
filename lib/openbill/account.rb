module Openbill
  class Account < Sequel::Model(ACCOUNTS_TABLE_NAME)
    def category
      Openbill::Category[category_id]
    end

    def amount
      Money.new amount_cents, amount_currency
    end

    def to_s
      key
    end
  end
end
