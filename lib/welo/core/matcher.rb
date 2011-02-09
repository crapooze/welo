
module Welo
  class Matcher
    attr_reader :params, :prefix

    # Initializes a new matcher for the set of params (a hash) a prefix may be
    # given, in which case, only the keys prefixed by the prefix
    # will be selected.
    def initialize(params, prefix='')
      @prefix = prefix.dup.freeze
      @params = if prefix.empty?
        params.dup.freeze
      else
        h = {}
        keys = params.keys.select do |k|
          k.start_with?(prefix)
        end
        keys.each do |k|
          h[k] = params[k]
        end
        h.freeze
      end
    end

    def missing_params?(*args)
      missing_params(*args).any?
    end

    def too_many_params?(*args)
      extra_params(*args).any?
    end

    def wrong_params_set?(*args)
      missing_params?(*args) or 
      too_many_params?(*args)
    end

  end

  class IdentifyingMatcher < Matcher
    def identifiers_for_params_matching(resource, ident=:default)
      resource.identifiers(ident, prefix).map{|id| id.sub(/^:/,'')}
    end

    def missing_params(resource, ident=:default)
      (identifiers_for_params_matching(resource, ident) - params.keys)
    end

    def extra_params(resource, ident=:default)
      (params.keys - identifiers_for_params_matching(resource, ident))
    end

    # Returns true if the params hash qualifies for identifying this resource.
    # prefixing is possible in case the hash's keys has prefixes
    # e.g., Foo = Struct.new(:a, :b) do
    #         include Resource
    #         identify :default, :a, :b
    #       end
    #      foo = Foo.new(1,2)
    #      params = { 'bla.a' => 1, 'bla.b' => 2 }
    #      Matcher.new(params, 'bla.').match?(foo, :default) 
    #      # => true
    # see Resource#identifiers and identifiers_for_params_matching for more on prefix.
    def match?(resource, ident=:default)
      return false if wrong_params_set?(resource, ident)
      pairs = [resource.identify(ident), identifiers_for_params_matching(resource, ident)].transpose
      pairs.inject(true) do |bool, pair|
        sym, param_name = *pair
        bool and resource.send(sym) == params[param_name]
      end
    end

    alias :=~ :match?
  end

  class EpithetMatcher < Matcher
    def epithets_for_params_matching(resource, epithet_resource, label)
      resource.epithets(label, prefix).map{|id| id.sub(/^:/,'')}
    end

    def missing_params(resource, epithet_resource, label)
      (epithets_for_params_matching(resource, epithet_resource, label) - params.keys)
    end

    def extra_params(resource, epithet_resource, label)
      (params.keys - epithets_for_params_matching(resource, epithet_resource, label))
    end

    def match?(resource, epithet_resource, label)
      return false if wrong_params_set?(resource, epithet_resource, label)
      pairs = [resource.epithet(label), 
        epithets_for_params_matching(resource, epithet_resource, label)].transpose
      pairs.inject(true) do |bool, pair|
        sym, param_name = *pair
        bool and resource.send(sym, epithet_resource) == params[param_name]
      end
    end

    alias :=~ :match?
  end
end
