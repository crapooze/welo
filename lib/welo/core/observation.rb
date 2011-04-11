
module Welo
  # DelayedObservation is a class representing a subsequent observation.
  DelayedObservation = Struct.new(:observation, :relationship, :path)

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
      st.perspective = name
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

      # The perspective of an ObservationStruct is the parts
      # of resource it's looking at.
      attr_accessor :perspective

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
    end
  end

  # An Observer is an object which is responsible for creating resources
  # observations.
  class Observer
    Registration = Struct.new(:event_name, :cb)

    # A hash mapping event name to their registrations
    attr_reader :registrations

    def initialize
      @registrations = {}
    end

    # Calls all the callback for the registrations in one event named according 
    # to the first parameter.
    # A second parameter can be passed to the callbacks.
    #
    # The name :observation should be reserved to the observing duties.
    # See observe_source for why.
    def event(name, obj=nil)
      regs = registrations[name]
      return unless regs
      regs.each do |reg|
        reg.cb.call(obj)
      end
    end

    # Registers a new callback given in the block parameter for the given event.
    # Returns a Registration instance, you should keep track of this instance if 
    # you plan to unregister it later.
    def register(event_name,&blk)
      registrations[event_name] ||= []
      reg = Registration.new(event_name,blk)
      registrations[event_name] << reg
      reg
    end

    # Removes exactly one registration given the Registration instance.
    # The parameter should be a value previously returned by register on the 
    # same object.
    def unregister(registration)
      regs = registrations[registration.event_name]
      raise ArgumentError, "no registratons for #{registration.event_name}" unless regs
      regs.delete(registration)
    end

    # Removes all the registrations for a given event name.
    def unregister_all(event_name)
      registrations.delete(event_name)
    end

    # Observe a source by calling it's observe method, and pushing it's
    # successive yielded values into a new instance of observation_struct.
    # Then calls the :observation event with the new observation as parameter.
    def observe_source(source, observation_struct)
      source.observe do |data|
        hash = {}
        observation_struct.members.each do |sym|
          hash[sym] = data[sym.to_s]
        end
        obs = observation_struct.for_hash(hash)
        obs._source_ = source
        event(:observation, obs)
      end
    end
  end
end
