module Openbill
  class GoodAvailability < Sequel::Model(GOODS_AVAILABILITIES_TABLE_NAME)
    many_to_one :account, class: 'Openbill::Account'
    many_to_one :good, class: 'Openbill::Good'

    def to_s
      value
    end
  end
end
