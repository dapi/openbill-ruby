module Openbill
  class Account < Sequel::Model(ACCOUNTS_TABLE_NAME)
    many_to_one :category, class: 'Openbill::Category'

    def amount
      Money.new amount_cents, amount_currency
    end

    def date_amount
      Money.new date_amount_cents, amount_currency
    end

    def date_amount_cents
      values[:date_amount_cents]
    end

    def <=> (other)
      id <=> other.id
    end

    def to_s
      key
    end

    def self.at_date(date)
      dataset
        .select_all(:openbill_accounts)
        .left_join(
          Sequel.as(:openbill_transactions, :t1),
          [
            Sequel.lit('t1.date <= ?', date),
            Sequel.or(
              t1__from_account_id: :openbill_accounts__id,
              t1__to_account_id: :openbill_accounts__id
            )
          ]
        )
        .select_append(
          Sequel.as(
            Sequel.lit('SUM(COALESCE((CASE openbill_accounts.id WHEN t1.from_account_id THEN -t1.amount_cents ELSE t1.amount_cents END)::bigint, 0))'),
            :date_amount_cents
          )
        )
        .group(:openbill_accounts__id)
    end
  end
end
