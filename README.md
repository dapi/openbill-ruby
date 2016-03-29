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

## Usage

### Создание системных счетов

```ruby
Openbill.config.database = 
  ActiveRecord::Base.connection.instance_variable_get('@config');


SystemRegistry = Openbill::Registry.new Openbill.current do |registry|
  registry.define :payments,      'Счет с которого поступает оплата'
  registry.define :subscriptions, 'Абонентская плата'
end
```

Таким образом в системом реестре появляется два счета `SystemRegistry[:payments]` и `SystemRegistry[:subscriptions]`

### Поддержка биллинга со стороны клиента (автоматическое создание клиентского счета):

```ruby
module AccountBilling
  extend ActiveSupport::Concern

  included do
    after_commit :attach_billing, on: :create
  end

  delegate :amount, to: :billing_account

  def billing_account
    Openbill.current.account([:accounts, id])
  end
end
```

Добавляем concern в модель ответсвенную за счет (например в User)


### Прием оплаты.

Оплата проводится транзакцией между системным счетом `payments` и счетом клиента.

```ruby
Openbill.current.make_transaction(
  // Счет списания
  from_account_id: Billing.payment.id,

  // Счет зачисление
  to_account_id:   user.billing_account.id,
  
  // Уникальный идентификатор транзакции
  uri:             Openbill.current.generate_uri(:transactions, 123),

  // Сумма транзакции. Валюта должна совпадать с обоими счетами
  amount:          Money(123, 'RUB'),

  // Не обязательное текстовое описание транзакции
  details:         'Оплата такая-то',

  // hash с данными транзакции для структурированного поиска в дальнейшем
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

