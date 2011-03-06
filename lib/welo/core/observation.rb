
module Welo
  class DelayedObservation 
    #Struct.new(:observation, :rel, :path)
    attr_accessor :observation, :relationship, :path
  end

  ObservationStruct = Class.new(Struct) do
    attr_accessor :_source
    unless members.include?(:source)
      alias :source :_source
    end

    class << self
      attr_accessor :maker, :perspective
      def for_hash(hash)
        vals = members.map do |k|
          rel = maker.resource.relationship(k)
          if rel
            DelayedObservation.new(self, rel, hash[k])
          else
            hash[k]
          end
        end
        self.new(*vals)
      end

      def for_source(source)
        raise NotImplemented
        #TODO: figure-out a good API
        obj = for_hash(source.to_h)
        obj._source = source
        obj
      end
    end
  end

  class ObservationSource
  end

  class ObservationMaker
    attr_accessor :resource, :structures
    def initialize(res=nil)
      @resource = res
      @structures = {}
    end

    def structure(name=:default, &blk)
      @structures[name] ||= create_structure!(name, &blk)
    end

    def create_structure!(name, &blk)
      persp = resource.perspective(name)
      raise ArgumentError.new("no such perspective: #{name} for #{resource}") unless persp
      st = ObservationStruct.new(*persp.fields, &blk)
      st.maker = self
      st.perspective = name
      st
    end
  end

  class Observer
    attr_reader :registrations, :models
    def initialize(models=[])
      @registrations = {}
      @models = models
    end
  end

  class FileSystemObserver < Observer
    FileSystemObservationSource = Struct.new(:root, :path)

    class DB
      include Derailleur::Application
      def initialize(models)
        super
        #creates the tree to map the DB structure to classes paths
        models.each do |model|
          path = model.path_model(:flat_db) #XXX allow to change the db perspective name
          node = build_route(path)
          node.content = model
        end
      end
    end


    #TODO 
    # - load from one path + file
    # - find many in the database/a database path
    # - callbacks to monitor changes with inotify
  end

  class HTTPObserver < Observer
    #TODO: use net/http or em-http
  end

end
