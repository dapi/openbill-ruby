require 'test_helper'

class OpenbillServiceTest < OpenbillTest
  KEY = 'uniqal_transaction_key'
  FIRST_COUNT = 1
  NEXT_COUNT = 2
  FIRST_AMOUNT = Money.new(100)
  NEXT_AMOUNT = Money.new(250)

  attr_reader :from_account, :to_account

  def setup
    @from_account = Openbill.service.create_account :from_account, category_id: default_category.id
    @to_account = Openbill.service.create_account :to_category, category_id: default_category.id
  end

  def test_upsert_transaction

    # Создаем транзакцию с нуля, а может быть и обновляем ту, что уже есть, мы не знаем
    #
    id = Openbill.service.upsert_transaction(
      from: from_account,
      to: to_account,
      amount: FIRST_AMOUNT,
      date: Date.today,
      key: KEY,
      details: 'test transaction',
      meta: { count: FIRST_COUNT }
    )

    refute_nil id

    assert_equal(-FIRST_AMOUNT, from_account.reload.amount)
    assert_equal(FIRST_AMOUNT, to_account.reload.amount)

    # Мы не знаем создана транзакция или нет, но делаем списание с другими данными,
    # но с точно таким-же ключем
    #
    next_id = Openbill.service.upsert_transaction(
      from: from_account,
      to: to_account,
      amount: NEXT_AMOUNT,
      date: Date.today,
      key: KEY,
      details: 'second transaction',
      meta: { count: NEXT_COUNT }
    )

    assert_equal id, next_id

    assert_equal(-NEXT_AMOUNT, from_account.reload.amount)
    assert_equal(NEXT_AMOUNT, to_account.reload.amount)

    transaction = Openbill.service.get_transaction id

    assert_equal transaction.meta, { 'count' => NEXT_COUNT.to_s }
  end
end
