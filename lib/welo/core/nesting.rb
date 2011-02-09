
module Welo
  # Nesting are not embeddings they just points to other resources with local
  # identification namings scheme
  class Nesting
    # The symbol for the method to call to get the 
    # nested resource
    attr_accessor :resource_sym

    # The symbol for the method to identify the
    # nested resource
    attr_accessor :identifier_sym

    def initialize(sym1, sym2)
      @resource_sym = sym1
      @identifier_sym = sym2
    end
  end
end
