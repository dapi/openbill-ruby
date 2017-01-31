require 'sequel'
require 'money'

module Openbill
  class Service
    ACCOUNT_IDENT_DELIMETER = '/'

    Error = Class.new StandardError
    NoSuchAccount = Class.new Error
    NoSuchCategory = Class.new Error
    WrongCurrency = Class.new Error

    attr_reader :db, :config

    def initialize(config)
      @config = config
      @db = Sequel.connect config.database, logger: config.logger, max_connections: config.max_connections, reconnect: true
      @db.extension :pagination
      @db.extension :pg_hstore

      load_models
    end

    def policies
      Openbill::Policy.dataset
    end

    def transactions
      Openbill::Transaction.dataset
    end

    def invoices
      Openbill::Invoice.dataset
    end

    def operations
      Openbill::Operation.dataset
    end

    def categories
      Openbill::Category.dataset
    end

    def webhook_logs
      Openbill::WebhookLog.dataset
    end

    def goods
      Openbill::Good.dataset
    end

    def goods_availabilities
      Openbill::GoodAvailability.dataset
    end

    # Return accounts repositiory (actualy sequel dataset)
    #
    def accounts
      Openbill::Account.dataset
    end

    def accounts_at_date(date)
      Openbill::Account.at_date date
    end

    def notify_transaction(transaction)
      transaction_id = transaction.is_a?(Openbill::Transaction) ? transaction.id : transaction
      db.execute "notify #{TRANSACTIONS_TABLE_NAME}, '#{transaction_id}'"
    end

    def good_units
      goods.select(:unit).distinct.order(Sequel.asc(:unit))
    end

    def get_category(id)
      Openbill::Category[id: id]
    end

    # @param ident - ident аккаунта в виде: [:category, :key]
    #
    # @param options - опции применяемые для создания аккаунта (см create_account)
    #
    def get_or_create_account_by_key(key, category_id:, currency: nil, details: nil, meta: {})
      account = get_account_by_key(key)
      currency ||= config.default_currency

      if account.present?
        # TODO: Do we need to update account details and meta?
        fail WrongCurrency, "Account currency is wrong #{account.amount_currency} <> #{currency}" unless account.amount_currency == currency
        return account
      else
        create_account key, category_id: category_id, currency: currency, details: details, meta: Sequel.hstore(meta)
      end
    end

    def get_account(account)
      case account
      when String
        get_account_by_id(account)
      when Symbol
        get_account_by_key(account)
      when Openbill::Account
        account
      else
        fail "Unknown type of account '#{account}' (#{account.class}). Must be Fixnum, Array or Openbill::Account"
      end
    end

    def get_account_by_id(id)
      Openbill::Account[id: id]
    end

    # @param key - key аккаунта
    def get_account_by_key(key)
      Openbill::Account[key: key.to_s]
    end

    def create_account(account_key, category_id:, id: nil, currency: nil, details: nil, meta: {})
      attrs = {
        category_id:     category_id,
        key:             account_key,
        details:         details,
        meta:            meta,
        amount_currency: currency || config.default_currency
      }
      unless id.nil?
        attrs[:id] = id
        Openbill::Account.unrestrict_primary_key
      end
      Openbill::Account.create(attrs)
    end

    def create_category(name, id: nil, parent_id: nil)
      attrs = { name: name, parent_id: parent_id }
      unless id.nil?
        attrs[:id] = id
        Openbill::Category.unrestrict_primary_key
      end
      Openbill::Category.create(attrs)
    end

    def account_transactions(ident)
      account = ident.is_a?(Openbill::Account) ? ident : get_account(ident)
      Openbill::Transaction
        .where('from_account_id = ? or to_account_id = ?', account.id, account.id)
    end

    # return tansaction id
    #
    def upsert_transaction(from:, to:, amount:, key:, details:, date:, meta: {})
      raise 'SQL server does not support conflict inserts. Use PostgreSQL v9.5 or greater' unless transactions.supports_insert_conflict?

      account_from = get_account from
      account_to = get_account to

      amount = prepare_amount amount, account_from.amount_currency

      attrs = {
        from_account_id: account_from.id,
        to_account_id:   account_to.id,
        amount_cents:    amount.cents,
        amount_currency: amount.currency.iso_code,
        date:            date,
        details:         details,
        meta:            Sequel.hstore(meta)
      }

      transactions
        .insert_conflict( target: :key, update: attrs )
        .insert(attrs.merge(key: key))
    end

    # @param key - уникальный текстовый ключ транзакции
    #
    def make_transaction(from:, to:, amount:, key:, details: , date: , meta: {})
      account_from = get_account from
      account_to = get_account to

      amount = prepare_amount amount, account_from.amount_currency

      Openbill::Transaction.create(
        from_account_id: account_from.id,
        to_account_id:   account_to.id,
        amount_cents:    amount.cents,
        amount_currency: amount.currency.iso_code,
        date:            date,
        key:             key,
        details:         details,
        meta:            Sequel.hstore(meta)
      )
    end

    def get_transaction(id)
      Openbill::Transaction[id: id]
    end

    def get_pending_webhooks_transactions
      Openbill::Transaction.with_pending_webhooks
    end

    private

    delegate :logger, to: Rails

    # get db schemas
    def load_models
      [Openbill::Transaction,
       Openbill::Account,
       Openbill::Category,
       Openbill::Policy,
       Openbill::Good,
       Openbill::GoodAvailability,
       Openbill::Operation,
       Openbill::WebhookLog].each do |model|
         model.db = db
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
  end
end
