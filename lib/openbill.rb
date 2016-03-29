require 'openbill/engine'
module Openbill
  autoload :Service,       'openbill/service'
  autoload :Account,       'openbill/account'
  autoload :Transaction,   'openbill/transaction'
  autoload :Configuration, 'openbill/configuration'
  autoload :Registry,      'openbill/registry'

  ACCOUNTS_TABLE_NAME     = :openbill_accounts
  TRANSACTIONS_TABLE_NAME = :openbill_transactions

  class << self
    def root
      File.dirname __dir__
    end

    def configure
      yield self.config
    end

    def config
      Configuration.instance
    end

    def current
      return @current if @current

      @current = Openbill::Service.new config
    end
  end
end
