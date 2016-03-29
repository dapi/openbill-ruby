module Openbill
  class Registry
    SYSTEM_NS = :system
    AccountNotFound = Class.new StandardError

    def initialize(service, system_ns = SYSTEM_NS)
      fail("Must be a Openbill::Service #{service}") unless service.is_a? Openbill::Service
      @service = service
      @system_ns = system_ns
      @accounts = {}
      yield self
      @accounts.freeze
      return @accounts
    rescue
      @system_ns = nil
    end

    # Находит, или создает аккаунт с указанным именем
    #
    def define(name, options)
      @accounts[name] = service.account([system_ns, name], options)
    end

    def [](name)
      @account[name]
    end

    def find(name)
      [name] || raise(AccountNotFound, name)
    end

    private

    attr_reader :service, :system_ns
  end
end
