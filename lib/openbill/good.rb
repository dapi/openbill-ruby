module Openbill
  class Good < Sequel::Model(GOODS_TABLE_NAME)
    many_to_one :group, class: 'Openbill::Good'

    def to_s
      title
    end
  end
end
