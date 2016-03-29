require 'sequel'
require 'uri'
require 'money'

module Openbill

  class Service
    PROTO = 'obp'.freeze
    HOST = 'local'.freeze

    def initialize(config)
      @config = config
      @database = Openbill::Database.new config.database
    end

    def generate_uri(resource, id)
      "${PROTO}://${HOST}/#{resource}/#{id}"
    end

    # @param uri - uri аккаунта в виде строки: "odp://local/resource/id"
    #              или в виде массива [resource, id]
    #
    # @param options - опции применяемые для создания аккаунта (см create_account)
    #
    def account(uri, options = {})
      uri = prepare_uri uri
      get_account_by_uri(uri) || create_account(uri, options)
    end

    def get_account_by_uri(uri)
      uri = prepare_uri uri
      Openbill::Account[uri: uri]
    end

    def create_account(uri, currency: nil, details: nil, meta: {})
      uri = prepare_uri uri
      Openbill::Account.create(
        uri:             uri,
        details:         details,
        meta:            meta,
        amount_currency: currency || config.default_currency
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
      return Money.new(amount, config.default_currency) if amount.is_a? Fixnum
      raise "amount parameter (#{amount}) must be a Money or a Fixnum"
    end

    def prepare_uri(uri)
      uri = generate_uri uri.first, uri.second if uri.is_a? Array
      URI(uri).to_s # Парсим и валидируем заодно
    end
  end
end
