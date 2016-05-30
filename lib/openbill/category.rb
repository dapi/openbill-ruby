module Openbill
  class Category < Sequel::Model(CATEGORIES_TABLE_NAME)
    def accounts_count
      # unknown
    end
  end
end
