require 'openbill/engine'

module Openbill
  autoload :Category,         'openbill/category'
  autoload :Account,          'openbill/account'
  autoload :Policy,           'openbill/policy'
  autoload :Service,          'openbill/service'
  autoload :Transaction,      'openbill/transaction'
  autoload :Operation,        'openbill/operation'
  autoload :WebhookLog,       'openbill/webhook_log'
  autoload :Configuration,    'openbill/configuration'
  autoload :Good,             'openbill/good'
  autoload :GoodAvailability, 'openbill/good_availability'
  autoload :Invoice,          'openbill/invoice'

  ACCOUNTS_TABLE_NAME             = :openbill_accounts
  CATEGORIES_TABLE_NAME           = :openbill_categories
  TRANSACTIONS_TABLE_NAME         = :openbill_transactions
  OPERATIONS_TABLE_NAME           = :openbill_operations
  WEBHOOK_LOGS_TABLE_NAME         = :openbill_webhook_logs
  POLICIES_TABLE_NAME             = :openbill_policies
  GOODS_TABLE_NAME                = :openbill_goods
  GOODS_AVAILABILITIES_TABLE_NAME = :openbill_goods_availabilities
  INVOICES_TABLE_NAME             = :openbill_invoices

  class << self
    def root
      File.dirname __dir__
    end

    def configure
      yield self.config
      service
    end

    def config
      Configuration.instance
    end

    def current
      deprecate 'Openbill.current is deprecated. Use Openbill.service instead'
      service
    end

    # Return default Openbill::Service instance
    #
    def service
      return @service if @service

      @service = Openbill::Service.new config
    end

    def deprecate(message)
      STDERR.puts "DEPRECATE: #{message}"
    end
  end
end
