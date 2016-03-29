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
      "#{PROTO}://#{HOST}/#{resource}/#{id}"
    end

    # @param uri - uri аккаунта в виде строки: "odp://local/resource/id"
    #              или в виде массива [resource, id]
    #
    # @param options - опции применяемые для создания аккаунта (см create_account)
    #
    def account(uri, currency: nil, details: nil, meta: {})
      uri = prepare_uri uri
      account = get_account_by_uri(uri)
      currency ||= config.default_currency

      if account.present?
        fail "Account currency is wrong #{account.amount_currency} <> #{currency}" unless account.amount_currency == currency
        # TODO update details and meta
        return account
      end

      create_account(uri, currency: currency, details: details, meta: meta)
    end

    def get_account_by_id(id)
      Openbill::Account[id: id]
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
    def make_transaction(from:, to:, amount:, uri:, details: , meta: {})
      account_from = get_account_id from
      account_to = get_account_id to

      amount = prepare_amount amount, account_from.amount_currency
      uri = prepare_uri uri

      Openbill::Transaction.create(
        from_account_id: account_from.id,
        to_account_id:   account_to.id,
        amount_cents:    amount.cents,
        amount_currency: amount.currency,
        uri:             uri,
        details:         details,
        meta:            meta
      )
    end

    private

    attr_reader :database, :config

    delegate :logger, to: Rails

    def get_account_id(account)
      case account
      when Fixnum
        get_account_by_uri(account)
      when String, Array
        get_account_by_uri(account)
      when Openbill::Account
        account
      else
        fail "Unknown type of account #{account}. Must be Fixnum, String, Array or Openbill::Account"
      end
    end

    def prepare_amount(amount, account_currency)
      if amount.is_a? Money
        unless amount.currency == account_currency
          fail "Amount currency is wrong #{amount.currency}<>#{account_currency}"
        end
        return amount
      end

      raise "amount parameter (#{amount}) must be a Money or a Fixnum" unless amount.is_a? Fixnum

      Money.new(amount, account_currency)
    end

    def prepare_uri(uri)
      uri = generate_uri uri.first, uri.second if uri.is_a? Array
      URI(uri).to_s # Парсим и валидируем заодно
    end
  end
end
