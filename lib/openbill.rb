require 'openbill/engine'
module Openbill
  autoload :Service,       'openbill/service'
  autoload :Account,       'openbill/account'
  autoload :Transaction,   'openbill/transaction'
  autoload :Configuration, 'openbill/configuration'

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

    def generate_uri(resource, id)
      "obp://local/#{resource}/#{id}"
    end

    def create_connection(&block)
      @create_connection_block = block
    end

    def current
      @current ||= Openbill::Service.new config.database_config
    end
  end
end
