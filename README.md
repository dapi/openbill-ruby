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
Openbill.configure do |config|
  config.default_currency = 'RUB'
  config.database = ActiveRecord::Base.connection.instance_variable_get('@config')
end

SystemRegistry = Openbill::Registry.new Openbill.current do |registry|
  registry.define :payments,      'Счет с которого поступает оплата'
  registry.define :subscriptions, 'Абонентская плата с клиентских счетов'
end
```

Таким образом в системом реестре появляется два счета `SystemRegistry[:payments]` и `SystemRegistry[:subscriptions]`

### Поддержка биллингово счета в клиентской модели:

```ruby
module OpenbillAccountSupport
  extend ActiveSupport::Concern

  included do
    after_commit :attach_billing, on: :create
  end

  def openbill_account
    Openbill.current.account([:accounts, id])
  end
end
```

Добавляем этот `concern` в модель ответсвенную за счет (например в `User`)

### Операции

Обычно со стороны пиложения необходимо производить несколько типовыхв операций:

1. Зачисление оплаты на счет клиента.
2. Списание со счета клиента (напримре ежемесячной оплаты).
3. Просмотр состояния счета клиента.

#### 1. Зачисление оплаты на счет клиента.

Оплата проводится транзакцией между системным счетом `:payments` и индивидуальным счетом клиента.

```ruby
Openbill.current.make_transaction(
  // Счет списания
  from: SystemRegistry[:payments],

  // Счет зачисление
  to:   user.opennill_account,
  
  // Уникальный идентификатор транзакции. Идентификтор должен содержать
  // ключи исключающие случайное повторное проведение данной транзакции.
  // Обычно сюда включают номер транзакции из платежного шлюза
  key:             'N123132131',

  // Сумма транзакции. Валюта должна совпадать с обоими счетами
  amount:          Money(123, 'RUB'),

  // Не обязательное текстовое описание транзакции. Например детали из платежного шлюза.
  details:         'Оплата такая-то',

  // Необязательнай hash с данными транзакции для структурированного поиска в дальнейшем
  meta:            { gateway: :cloudpayments }
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/openbill. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

