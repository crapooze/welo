
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

  class Link
    include CanBeLazy

    # The pointing resource
    attr_accessor :from

    # The pointed resource
    attr_accessor :to

    # The labeling for this link
    attr_accessor :label

    # The locality for this link
    attr_accessor :local

    # Creates a link to the pointed resource to,
    # it must respond to :path
    def initialize(from, to=nil, params={}, &blk)
      @from = from
      @to = to
      @lazy = params.has_key?(:lazy) ? params[:lazy] : true
      @label = params[:label] 
      @local = params[:local] 
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
    def nesting
      @nesting ||= from.nesting(label)
    end

    # Gets the identifying scheme corresponding to this link.
    # For now the identification scheme is written in the to resource.
    # Later, we'll try to be able to identify pointed resources with
    # an identifying scheme local to the from resource.
    def identify
      identify = if nesting
                   nesting.identifier_sym
                 else
                   :default
                 end
    end

    # Returns an absolute version of the path.
    # Meaning that we use the default identifying scheme.
    def to_absolute_path
      File.join('', to.path(:default).to_s)
    end

    # Returns a relative version of the path.
    # We can use a different identification scheme of the pointed resource.
    # Later, we'll try to be able to identify pointed resources with
    # a identifying scheme local to the from resource.
    def to_relative_path
      File.join('.', to.path(identify).to_s)
    end

    def to_local_path
      File.join('.', from.epithet_path_to(to, label).to_s)
    end

    # Returns a string representation of this link
    # (i.e., an path)
    def to_s
      if nesting
        to_relative_path
      elsif local
        to_local_path
      else
        to_absolute_path
      end
    end
  end

  class LinksEnumerator
    include Enumerable

    # the enumerating object
    attr_reader :enum

    def initialize(enum=nil, params={}, &blk)
      @enum = enum || blk
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
