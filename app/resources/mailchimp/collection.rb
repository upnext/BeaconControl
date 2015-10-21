module Mailchimp
  class Collection < Array
    attr_accessor :parent_ids

    def initialize(owner_class)
      @owner_class = owner_class
      super()
    end

    def create(params, ids=[])
      ids = (parent_ids || ids) || []
      @owner_class.create params, ids
    end

    def build(params, ids=[])
      @owner_class.new(params)
    end
  end
end