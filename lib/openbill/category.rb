module Openbill
  class Category
    include Virtus.model

    attribute :name, String
    attribute :accounts_count, Integer
  end
end
