
module Welo
  class Relationship
    # The symbol for the method to call to get the 
    # related resource
    attr_accessor :sym

    # The kinds of relationship
    attr_accessor :kinds

    # The klass of the related resource
    attr_accessor :klass

    # Returns true if the kinds are incompatible
    # current incompatibilities:
    # - :one and :many at the same time
    def self.incompatible_kinds?(kinds)
      ((kinds & [:one, :many]).size == 2) 
    end

    # creates a new relationship for sym and klass, with all the given kinds
    # providing incompatibles kinds lead to an ArgumentError
    def initialize(sym, klass, kinds)
      raise ArgumentError, "incompatible kinds" if self.class.incompatible_kinds?(kinds)
      @sym = sym
      @klass = klass
      @kinds = kinds
    end

    # true if at least one of the kinds is :one
    def one?
      kinds.include?(:one)
    end

    # true if at least one of the kinds is :many
    def many?
      kinds.include?(:many)
    end

    def alias?
      kinds.include?(:alias)
    end
  end
end
