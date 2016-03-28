require 'sequel'
require 'uri'
require 'money'

module Openbill
  MAX_CONNECTIONS         = 10
  DEFAULT_CURRENCY        = 'RUB'.freeze

  class Service
    def initialize(db_config)
      init_db db_config
    end

    def get_account_by_uri(uri)
      Openbill::Account[uri: uri]
    end

    def create_account(uri, currency: DEFAULT_CURRENCY, details: nil, meta: {})
      uri = prepare_uri uri
      Openbill::Account.create(
        uri:             uri,
        details:         details,
        meta:            meta,
        amount_currency: currency
      )
    end

    # @param uri - уникальный uri транзакции
    def make_transaction(from_account_id:, to_account_id:, amount:, uri:, details: nil, meta: {})
      amount = prepare_amount amoount
      uri = prepare_uri uri

      Openbill::Transaction.create(
        from_account_id: from_account_id,
        to_account_id:   to_account_id,
        amount_cents:    amount.cents,
        amount_currency: amount.currency,
        uri:             uri,
        details:         details,
        meta:            meta
      )
    end

    private

    attr_reader :db_config, :db

    delegate :logger, to: Rails

    def prepare_amount(amount)
      return amount if amount.is_a? Money
      return Money.new(amount, DEFAULT_CURRENCY) if amount.is_a? Fixnum
      raise "amount parameter (#{amount}) must be a Money or a Fixnum"
    end

    def prepare_uri(uri)
      URI(uri).to_s # Парсим и валидируем заодно
    end

    def init_db(db_config)
      @db_config = db_config
      @db = Sequel.connect db_config, logger: logger, max_connections: MAX_CONNECTIONS
      @db.extension :pagination
      @db.extension :pg_hstore
    end
  end
end
