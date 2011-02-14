
module Welo
  class Perspective
    attr_reader :name
    attr_reader :fields #symbols or relationships?

    def initialize(name, fields)
      @name = name
      @fields = fields
    end
  end
end
