
module Welo
  ObservationStruct = Class.new(Struct) do
    class << self
      attr_accessor :maker, :perspective
      def for_hash(hash)
        vals = members.map do |k|
          hash[k]
        end
        self.new(*vals)
      end
    end
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
end
