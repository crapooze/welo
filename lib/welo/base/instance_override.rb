
module Welo
  module InstanceOverride
    # An attribute to possibly override the class' base_path
    attr_writer :base_path

    # An attribute to possibly override the class' identification
    attr_writer :identifiers

    # An attribute to possibly override the class' relationships
    attr_writer :relationships

    # An attribute to possibly override the class' nestings
    attr_writer :nestings

    # An attribute to possibly override the class' perspectives
    attr_writer :perspectives

    # Returns the base_path, or fallback to the class' one
    def base_path
      @base_path || self.class.base_path
    end

    # Returns the path model, based on current's identifiers
    def path_model(ident=:default, prefix='')
      File.join(base_path, identifiers(ident, ':' + prefix))
    end

    # Returns the identifiers fields, or fallback to the class' one
    def identify(persp=:default)
      if @identifiers
        @identifiers[persp] || self.class.identify(persp)
      else
        self.class.identify(persp)
      end
    end

    # Returns the perspective, or fallback to the class' one
    def perspective(sym)
      if @perspectives
        @perspectives[sym]
      else
        self.class.perspective(sym)
      end
    end

    # Returns the relationship, or fallback to the class' one
    def relationship(sym)
      if @relationships
        @relationships[sym]
      else
        self.class.relationship(sym)
      end
    end

    # Returns the epithet, or fallback to the class' one
    def epithet(sym)
      if @epithets
        @epithets[sym]
      else
        self.class.epithet(sym)
      end
    end

    # Returns the nesting, or fallback to the class' one
    def nesting(resource_sym)
      if @nestings
        @nestings[resource_sym]
      else
        self.class.nesting(resource_sym)
      end
    end

    # Similar to the class' structure, but called with overrides
    def structure(name)
      persp = perspective(name)
      raise ArgumentError.new("no such perspective: #{name} for #{self}") unless persp
      fields = persp.fields
      fields.map do |field|
        rel = relationship(field)
        (rel || field)
      end
    end
  end
end
