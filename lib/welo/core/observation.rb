
require 'derailleur'

module Welo
  # DelayedObservation is a class representing a subsequent observation.
  class DelayedObservation 
    attr_accessor :observation, :relationship, :path
  end

  # An ObservationStruct is a special Struct (i.e. a class whose 
  # instances are structures).
  ObservationStruct = Class.new(Struct) do
    # The source for an observation instance is the object from which it could
    # be observed. Many applications may not matter, but some do.
    attr_accessor :_source_
    alias :source :_source_

    # Creates a new structure, class which fields correspond to the perspective
    # named name in resource.  If a block is passed, then it is evaluated in
    # the context of the new structure (like Struct.new { ... }).
    #
    # Normally, this method would be inherited by the structure, but we do not want to.
    # Thus we undef it in self.inherited (see self.inherited).
    def self.new_for_resource_in_perspective(resource, name, &blk)
      persp = resource.perspective(name)
      raise ArgumentError.new("no such perspective: #{name} for #{resource}") unless persp
      st = self.new(*persp.fields, &blk)
      st.resource = resource
      st
    end

    # Hook to remove the new_for_resource_in_perspective methods, which is
    # designed only for ObservationStruct but is inherited by the Struct
    # classes if nothing is done.
    def self.inherited(klass)
      klass.instance_eval do 
        undef :new_for_resource_in_perspective
      end
    end

    class << self
      # The resource of an ObservationStruct is the type 
      # of resource it's looking at.
      attr_accessor :resource

      # Instanciates a new struct object (i.e., not a Struct class).  The
      # fields are populated from the key/value pairs from hash.  If the
      # structure fields correspond to a relationship, then a
      # DelayedObservation object is created. It will then be the
      # responsibility of the developper to continue observing the delayed
      # observation or not.
      def for_hash(hash)
        vals = members.map do |k|
          rel = resource.relationship(k)
          if rel
            DelayedObservation.new(self, rel, hash[k])
          else
            hash[k]
          end
        end
        self.new(*vals)
      end

      def for_source(src)
        raise NotImplemented
        #TODO: figure-out a good API instead of source.to_h, will depend on the source class
        obj = for_hash(source.to_h)
        obj._source_ = src
        obj
      end
    end
  end

  class ObservationSource
    #XXX TODO
  end

  # An Observer is an object which is responsible for creating.
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
          path = model.path_model(:flat_db) #XXX allow to change the db identifying name
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
