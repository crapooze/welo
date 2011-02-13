
module Welo
  autoload :Link, 'welo/core/link'
  autoload :LinksEnumerator, 'welo/core/link'
  autoload :Relationship, 'welo/core/relationship'
  autoload :Perspective, 'welo/core/perspective'
  autoload :Nesting, 'welo/core/nesting'
  autoload :IdentifyingMatcher, 'welo/core/matcher'
  autoload :EpithetMatcher, 'welo/core/matcher'

  module Resource

    # A simple hook to extend the ClassMethods
    def self.included(mod)
      mod.extend ClassMethods
    end

    module ClassMethods
      # A hook to duplicates 
      # * relationships
      # * perspectives 
      # * identification
      # * base_path
      # Such that the subclass looks like the parent one
      def inherited(klass)
        relationships.each_pair do |k,v|
          klass.relationships[k] = v
        end
        nestings.each_pair do |k,v|
          klass.nestings[k] = v
        end
        perspectives.each_pair do |k,v|
          klass.perspectives[k] = v
        end
        identifiers_hash.each_pair do |k,v|
          klass.identifiers_hash[k] = v
        end
        klass.base_path base_path
      end

      # The hash of relationships with other resources
      def relationships
        @relationships ||= {}
      end

      # The hash of nestings of other resources
      def nestings
        @nestings ||= {}
      end

      # If one argument, returns the relationship with the given name
      # If more than one argument, registers a new relationship,
      # possibly overwriting it.
      def relationship(sym, klass=nil, *kinds)
        if klass
          relationships[sym] = Relationship.new(sym, klass, *kinds)
        else
          relationships[sym]
        end
      end

      # The hash of perspectives for this resource.
      def perspectives
        @perspectives ||= {}
      end

      # If one argument, returns the perspective for the given name, 
      # or the :default one if it exists
      # If more than one argument, registers a new perspective
      def perspective(name, syms=nil)
        if syms.nil?
          perspectives[name] || perspectives[:default]
        else
          perspectives[name] = Perspective.new(name, *syms)
        end
      end

      # If one argument, returns the nesting for the given resource_sym
      # If two arguments: creates a nesting of a resource in this resource
      def nesting(resource_sym, identifier_sym=nil)
        if identifier_sym.nil?
          nestings[resource_sym]
        else
          nestings[resource_sym] = Nesting.new(resource_sym, identifier_sym)
        end
      end

      # Returns the downcased last part of the ruby name
      def default_base_path_name
        self.name.split('::').last.downcase
      end

      # If there is one argument, sets the base_path,
      # otherwise returns the base_path, if not set, will fallback to
      # the default_base_path_name
      def base_path(val=nil)
        if val
          @base_path = val
        else
          @base_path || default_base_path_name
        end
      end

      # An hash to log the identifiers, by default, uses [:uuid]
      def identifiers_hash
        @identifiers_hash ||= {:default => [:uuid]}
      end

      # If there is no argument, returns the identification fields 
      # (defaults to [:uuid]).
      # Otherwise, sets the identification fields.
      # Fields are symbols of methods that will be sent to the instances.
      # Since they may be used to build an URL, identifying fields
      # must respond to :to_s.
      # See Resource#identifying_path_part
      def identify(sym, vals=nil)
        if vals.nil?
          identifiers_hash[sym]
        else
          identifiers_hash[sym] = vals
        end
      end

      # Returns array of formatted strings from the identification fields.
      # a prefix may be appended before the identification field 
      # e.g.
      # 'foo' (no prefix) => 'foo'
      # 'foo' (prefix:'bla.') => 'bla.foo'
      def identifiers(ident, prefix='')
        identify(ident).map{|sym| "#{prefix}#{sym}"}
      end

      def epithets_hash
        @epithets_hash ||= {}
      end

      def epithet(sym, vals=nil)
        if vals.nil?
          epithets_hash[sym]
        else
          epithets_hash[sym] = vals
        end
      end

      # Returns array of formatted strings from the epithets fields.
      # a prefix may be appended before the epithets field 
      # e.g.
      # 'foo' (no prefix) => 'foo'
      # 'foo' (prefix:'bla.') => 'bla.foo'
      def epithets(label, prefix='')
        epithet(label).map{|sym| "#{prefix}#{sym}"}
      end

      # Returns the path model for items of this resource, 
      # including an optional prefix
      # e.g. class Foo
      #        base_path 'foo'
      #        identify :default, :bar
      #      end
      #
      #      Foo.path_model(ident, 'pfx.')
      #      #=> 'foo/:pfx.bar'
      def path_model(ident, prefix='')
        File.join(base_path, identifiers(ident, ':' + prefix))
      end

      # Returns the structure associated to the selected perspective
      # the structure replace the perspective's fields by relationships whenever
      # it's possible
      def structure(name)
        persp = perspective(name)
        raise ArgumentError.new("no such perspective: #{name} for #{self}") unless persp
        fields = persp.fields
        fields.map do |field|
          rel = relationship(field)
          (rel || field)
        end
      end
    end # ClassMethods

    # Shorthand for class' base_path
    def base_path
      self.class.base_path
    end

    # Shorthand for class' path_model
    def path_model(ident=:default, prefix='')
      self.class.path_model(ident, prefix)
    end

    # Shorthand for class' identify
    def identify(ident=:default)
      self.class.identify(ident)
    end

    # Shorthand for class' epithet
    def epithet(name)
      self.class.epithet(name)
    end

    # Shorthand for class' perspective
    def perspective(sym)
      self.class.perspective(sym)
    end

    # Shorthand for class' relationship
    def relationship(sym)
      self.class.relationship(sym)
    end

    # Shorthand for class' nesting
    def nesting(resource_sym)
      self.class.nesting(resource_sym)
    end

    # Returns the resource's path part mapping the various fields.
    # The objects must respond to .to_s and return a value such that
    # the URL part is valid (esp. no whitespace)
    # This method does NOT check wether the return of .to_s builds a
    # valid URL part
    def identifying_path_part(ident=:default)
      File.join identify(ident).map{|sym| send(sym).to_s}
    end

    # Returns the full URL of this object
    def path(ident=:default)
      tail = identifying_path_part(ident)
      if tail.empty?
        base_path
      else
        File.join base_path, tail
      end
    end

    # Same as Resource.identifiers
    def identifiers(ident=:default, prefix='')
      identify(ident).map{|sym| ":#{prefix}#{sym}"}
    end

    # Shorthand for class' structure
    def structure(name)
      self.class.structure(name)
    end

    # Returns the structure as an array of pairs which first object is the
    # field name, the second object being the value.
    # When the class' structure mandates a Relationship, then the
    # second object of the pair is a Link to the related resource,
    # or an LinksEnumerator if it has many resources.
    def structure_pairs(name) 
      structure(name).map do |rel|
        sym = nil
        ret = case rel
              when Symbol
                sym = rel
                send(sym)
              when Relationship
                sym = rel.sym
                link_for_rel(rel)
              end #case rel
        [sym, ret]
      end
    end

    def link_for_rel(rel)
      if rel.one?
        single_link_for_rel(rel)
      elsif rel.many?
        links_enumerator_for_rel(rel)
      else
        raise ArgumentError, "unkown relationship kinds #{rel.kinds}"
      end #case rel.kind
    end

    # returns a lazy link loader for the relationship
    # i.e., the evaluation of the sym method may be delayed
    def single_link_for_rel(rel)
      sym = rel.sym
      Link.new(self, nil, :label => sym, :local => rel.alias?) do 
        send(sym)
      end
    end

    # returns a lazy link loader enumerator for the relationship
    # it will yield a link
    def links_enumerator_for_rel(rel)
      sym = rel.sym
      LinksEnumerator.new do |&blk|
        send(sym).each do |i|
          blk.call Link.new(self, i, :label => sym, :local => rel.alias?)
        end
      end
    end

    def match_params?(params, ident=:default, prefix='')
      IdentifyingMatcher.new(params, prefix).match?(self, ident)
    end

    alias uuid object_id

    def epitheting_path_part(resource, label)
      File.join epithet(label).map{|sym| send(sym, resource).to_s}
    end

    def epithet_path_to(resource, label)
      File.join label.to_s, epitheting_path_part(resource,label)
    end

    # Same as Resource.epithets
    def epithets(label, prefix='')
      epithet(label).map{|sym| ":#{prefix}#{sym}"}
    end

    def epithet_resource_match_params?(resource, params, label, prefix='')
      EpithetMatcher.new(params, prefix).match?(self, resource, label)
    end

  end  # Resource
end # Welo
