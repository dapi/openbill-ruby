module Openbill
  class Registry
    DEFAULT_CATEGORY = :common
    AccountNotFound = Class.new StandardError

    attr_reader :accounts

    def initialize(service, category = DEFAULT_CATEGORY)
      fail("Must be a Openbill::Service #{service}") unless service.is_a? Openbill::Service
      @service = service
      @category = category
      @accounts = {}
      yield self
      @accounts.freeze
    end

    # Находит, или создает аккаунт с указанным именем
    #
    def define(name, details)
      accounts[name] = service.account([category, name], details: details)
    end

    def [](name)
      accounts[name]
    end

    def find(name)
      [name] || raise(AccountNotFound, name)
    end

    private

    attr_reader :service, :category
  end
end
