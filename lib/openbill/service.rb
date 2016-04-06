require 'sequel'
require 'money'

module Openbill

  class Service
    def initialize(config)
      @config = config
      # @database = Openbill::Database.new config.database
    end

    # @param ident - ident аккаунта в виде: [:category, :key]
    #
    # @param options - опции применяемые для создания аккаунта (см create_account)
    #
    def account(ident, currency: nil, details: nil, meta: {})
      account = get_account(ident)
      currency ||= config.default_currency

      if account.present?
        fail "Account currency is wrong #{account.amount_currency} <> #{currency}" unless account.amount_currency == currency
        # TODO update details and meta
        return account
      end

      create_account(ident, currency: currency, details: details, meta: meta)
    end

    def get_account_by_id(id)
      Openbill::Account[id: id]
    end

    # @param ident - ident аккаунта в виде: [:category, :key]
    def get_account(ident)
      category, key = prepare_ident ident
      Openbill::Account[category: category, key: key]
    end

    def create_account(ident, currency: nil, details: nil, meta: {})
      category, key = prepare_ident ident
      Openbill::Account.create(
        category:        category,
        key:             key,
        details:         details,
        meta:            meta,
        amount_currency: currency || config.default_currency
      )
    end

    def account_transactions(ident)
      account = ident.is_a?(Openbill::Account) ? ident : get_account(ident)
      Openbill::Transaction
        .where('from_account_id = ? or to_account_id = ?', account.id, account.id)
    end

    # @param key - уникальный текстовый ключ транзакции
    #
    def make_transaction(from:, to:, amount:, key:, details: , meta: {})
      account_from = get_account_id from
      account_to = get_account_id to

      amount = prepare_amount amount, account_from.amount_currency

      Openbill::Transaction.create(
        from_account_id: account_from.id,
        to_account_id:   account_to.id,
        amount_cents:    amount.cents,
        amount_currency: amount.currency,
        key:             key,
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
        get_account_by_id(account)
      when Array
        get_account(account)
      when Openbill::Account
        account
      else
        fail "Unknown type of account #{account}. Must be Fixnum, Array or Openbill::Account"
      end
    end

    def prepare_ident(ident)
      fail "ident has wrong size" unless ident.count == 2
      return ident.first.to_s, ident.second.to_s
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
  end
end
