require 'openbill/engine'

module Openbill
  autoload :Category,      'openbill/category'
  autoload :Account,       'openbill/account'
  autoload :Service,       'openbill/service'
  autoload :Transaction,   'openbill/transaction'
  autoload :Configuration, 'openbill/configuration'
  autoload :Registry,      'openbill/registry'
  autoload :Database,      'openbill/database'

  ACCOUNTS_TABLE_NAME     = :openbill_accounts
  TRANSACTIONS_TABLE_NAME = :openbill_transactions

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
