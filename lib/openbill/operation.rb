module Openbill
  class Operation < Sequel::Model(OPERATIONS_TABLE_NAME)
    many_to_one :from_account, class: 'Openbill::Account'
    many_to_one :to_account, class: 'Openbill::Account'
  end
end
