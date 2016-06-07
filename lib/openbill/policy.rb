module Openbill
  class Policy < Sequel::Model(POLICIES_TABLE_NAME)
    many_to_one :from_category, class: 'Openbill::Category'
    many_to_one :to_category, class: 'Openbill::Category'
    many_to_one :from_account, class: 'Openbill::Account'
    many_to_one :to_account, class: 'Openbill::Account'

    def to_s
      name
    end
  end
end
