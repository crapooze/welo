
module Welo
  # Embeddings are a way to embed the structure of another resource within
  # another without actually linking them.
  # From an external observer, it is not possible to know wether a resource is
  # embedded inside another.
  class Embedding
    # The symbol for the method to call to get the 
    # embedded resource
    attr_accessor :resource_sym

    # The perspective with which we embed the resource
    attr_accessor :embedded_resource_perspective

    def initialize(sym1, sym2)
      @resource_sym = sym1
      @embedded_resource_perspective = sym2
    end
  end
end
