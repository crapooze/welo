module Welo
  module CanBeLazy
    # A flag to say if this object is lazy or not
    attr_accessor :lazy

    # A hash of blocks between methods name and lazy evaluations
    attr_accessor :lazy_blocks

    def lazy_blocks
      @lazy_blocks ||= {}
    end

    # true if lazy
    def lazy?
      (@lazy && true) or @lazy.nil?
    end
  end

  class Embedder
    include CanBeLazy

    # The embedding resource
    attr_accessor :from

    # The embedded resource
    attr_accessor :to

    # The labeling for this embedder
    attr_accessor :label

    # Creates an embedder of the embedded resource to
    def initialize(from, to=nil, params={}, &blk)
      @from = from
      @to = to
      @lazy = params.has_key?(:lazy) ? params[:lazy] : true
      @label = params[:label] 
      lazy_blocks[:to] = blk if block_given?
    end

    # If the link is lazy and there is no value to @to,
    # will evaluate the :to lazy_block and set to to this value.
    # If the link is not lazy, will just return @to
    def to
      if @lazy
        @to ||= lazy_blocks[:to].call
      else
        @to
      end
    end

    # Gets the nesting of the from resource of this link.
    def embedding
      @embedding ||= from.embedding(label)
    end

    def perspective
      embedding.embedded_resource_perspective
    end
  end

  class EmbeddersEnumerator
    include Enumerable

    # the enumerating object
    attr_reader :enum

    # The labeling for this embedder, may be useful for knowing what the enumerator will spit out
    attr_accessor :label

    def initialize(enum=nil, params={}, &blk)
      @enum = enum || blk
      @label = params[:label]
    end

    def each
      if enum.respond_to? :call
        enum.call{|i| yield(i)}
      else
        enum.each{|i| yield(i)}
      end
    end
  end
end

