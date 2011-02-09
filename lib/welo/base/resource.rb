
require 'welo/core/resource'
module Welo
  module Resource

    # returns a text representation of the resource, under
    # the persp perspective, 
    # the format is not standardized, suitable for dev cycles
    def to_text(persp)
      ret = ''
      structure_pairs(persp).each do |k,val|
        ret << "##{k}\n"
        if val.respond_to? :map
          ret << val.map{|v| v.to_s}.join("\n")
        else
          ret << val.to_s
        end
        ret << "\n"
      end
      ret
    end

    # returns an array of pairs of fields name and fields values 
    # for the perspective.
    #
    # the order of the pairs is the same as the fields in the perspective
    #
    # Links to other resources are represented as urls by sending
    # them the :to_s method.
    # the name of this method comes from the fact that Links are serialized to
    # strings
    def serialized_pairs(persp)
      ary = structure_pairs(persp).map do |sym, val|
        i1 = case val
             when Link
               val.to_s
             when LinksEnumerator
               val.map{|v| v.to_s}
             else
               val
             end
        [sym, i1]
      end
    end

    # similar to to_rb_hash, but with the urls serialized
    def to_serialized_hash(persp)
      Hash[serialized_pairs(persp)]
    end

    # returns a JSON representation of the resource, under
    # the persp perspective
    def to_json(persp)
      to_serialized_hash(persp).to_json
    end

    # returns a YAML representation of the resource, under
    # the persp perspective
    def to_YAML(persp)
      YAML.dump to_serialized_hash(persp)
    end

    # shortcut to call  to_#{ext}
    def to_ext(ext, persp=:default)
      meth = ext.sub(/^\./, 'to_')
      send(meth, persp)
    end
  end
end
