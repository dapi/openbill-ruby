module Openbill
  class Policy < Sequel::Model(POLICIES_TABLE_NAME)
    def to_s
      name
    end
  end
end
