module Openbill
  class Transaction < Sequel::Model(TRANSACTIONS_TABLE_NAME)
    many_to_one :from_account, class: 'Openbill::Account'
    many_to_one :to_account, class: 'Openbill::Account'
    many_to_one :good, class: 'Openbill::Good'
    one_to_many :webhook_logs, class: 'Openbill::WebhookLog', order: Sequel.desc(:created_at)
    one_to_one :last_webhook_log, class: 'Openbill::WebhookLog', order: Sequel.desc(:created_at), limit: 1

    one_to_one :reversation_transaction, class: 'Openbill::Transaction', key: :reverse_transaction_id, primary_key: :id

    # Original transaction
    one_to_one :reverse_transaction, class: 'Openbill::Transaction', primary_key: :reverse_transaction_id, key: :id

    def <=> (other)
      id <=> other.id
    end

    def amount
      Money.new amount_cents, amount_currency
    end
  end
end
