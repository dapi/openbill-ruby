module Openbill
  class Registry
    SYSTEM_NS = :system
    AccountNotFound = Class.new StandardError

    attr_reader :accounts

    def initialize(service, system_ns = SYSTEM_NS)
      fail("Must be a Openbill::Service #{service}") unless service.is_a? Openbill::Service
      @service = service
      @system_ns = system_ns
      @accounts = {}
      yield self
      @accounts.freeze
    end

    # Находит, или создает аккаунт с указанным именем
    #
    def define(name, details)
      accounts[name] = service.account([system_ns, name], details: details)
    end

    def [](name)
      accounts[name]
    end

    def find(name)
      [name] || raise(AccountNotFound, name)
    end

    private

    attr_reader :service, :system_ns
  end
end
