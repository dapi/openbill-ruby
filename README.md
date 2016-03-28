# Openbill

Это модуль для биллиноговой системы [openbill-core](https://github.com/dapi/openbill-core).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'openbill-ruby'
```

And then execute:

    $ bundle

Migrate database:

    $ rake db:migrate

Add database configurartion to `./config/initializers/openbill.rb`

```ruby
Openbill.config.database = ActiveRecord::Base.connection.instance_variable_get('@config');
```

## Usage

### Создание системных счетов


Рекомендую создать такой сервис для работы с системными счетами:

```ruby
module Billing
  NS = :system

  class << self
    def payments
      account :payments, 'Счет с которого поступает оплата'
    end

    def subscriptions
      account :subscriptions, 'Абонентская плата'
    end

    private

    # Находит, или создает аккаунт с указанным именем
    #
    def account(path, details)
      # Создаем uri аккаунта из его названия
      uri = Openbill.generate_uri NS, path

      Openbill.get_account_by_uri(uri) ||
        Openbill.create_account(uri, details: details)
    end
  end
end
```

Таким образом в системе появляется два счета `Billing.payments` и `Billing.subscriptions`

### Поддержка биллинга со стороны клиента (автоматическое создание клиентского счета):

```
module AccountBilling
  extend ActiveSupport::Concern

  included do
    after_commit :attach_billing, on: :create
  end

  delegate :amount, to: :billing_account

  def billing_account
    find_billing || attach_billing
  end

  private

  def account_uri
    Openbill.generate_uri :accounts, id
  end

  def find_billing
    Openbill.current.get_account_by_uri account_uri
  end

  def attach_billing
    Openbill.current.create_account account_uri
  end
end
```

Добавляем concern в модель ответсвенную за счет (например в User)


### Прием оплаты.

Оплата проводится транзакцией между системным счетом `payments` и счетом клиента.

```ruby
Openbill.current.make_transaction(
  from_account_id: Billing.payment.id,
  to_account_id:   user.billing_account.id,
  amount:          Money(123),
  details:         'Оплата такая-то',
  meta:            { key: 'value' } // не обязательно
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/openbill. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

