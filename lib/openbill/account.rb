module Openbill
  class Account < Sequel::Model(ACCOUNTS_TABLE_NAME)
    many_to_one :category, class: 'Openbill::Category'

    def amount
      Money.new amount_cents, amount_currency
    end

    def <=> (other)
      id <=> other.id
    end

    def to_s
      key
    end
  end
end
