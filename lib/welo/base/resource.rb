
require 'welo/core/resource'
module Welo
  module Resource

    # returns a text representation of the resource, under
    # the persp perspective, 
    # the format is not standardized, suitable for dev cycles
    def to_text(persp, ident=1)
      ret = ''
      structure_pairs(persp).each do |k,val|
        ret << "#"*ident + "#{k}\n"
        case val
        when Embedder
          ret << val.to.to_text(val.perspective, ident+1)
        when EmbeddersEnumerator
          val.each do |v| 
            ret << v.to.to_text(v.perspective, ident+1)
          end
        else
          if val.respond_to? :map
            ret << val.map{|v| v.to_s}.join("\n")
          else
            ret << val.to_s
          end
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

    def embedder_to_serialized_hash(embedder)
      embedder.to.to_serialized_hash(embedder.perspective)
    end

    # similar to serialized_pairs, but with the Embedders serialized as hash
    # this method is cross recursive with to_serialized_hash
    def hash_flattened_pairs(persp)
      serialized_pairs(persp).map do |sym,val|
        new_val = case val
                  when Embedder
                    val.to_serialized_hash
                    embedder_to_serialized_hash(val)
                  when EmbeddersEnumerator
                    val.map{|v| embedder_to_serialized_hash(v)}
                  else
                    val
                  end
        [sym,new_val]
      end
    end

    # similar to to_rb_hash, but with the urls serialized
    # this method is cross recursive with hash_flattened_pairs
    def to_serialized_hash(persp)
      Hash[hash_flattened_pairs(persp)]
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
