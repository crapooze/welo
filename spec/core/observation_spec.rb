
require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'welo/core/observation'
require 'welo/core/resource'

describe ObservationMaker, 'a structure mimicking a resource' do
  before :each do 
    @resource = :foo
  end

  it "should have no resource" do
    ObservationMaker.new.resource.should be_nil
  end

  it "should gets the resource" do
    ObservationMaker.new(@resource).resource.should eql(:foo)
  end
end

describe ObservationMaker, 'structuring' do
  before :all do
    @klass = Class.new do
      include Welo::Resource
      perspective :foo, [:a, :b, :c]
    end
  end

  before :each do
    @observation = ObservationMaker.new(@klass)
  end

  it "should outputs a Struct" do
    st = @observation.structure(:foo)
    st.should be_a(Class)
    st.ancestors.include?(Struct).should be_true
  end

  it "should output a struct with same members" do
    st = @observation.structure(:foo)
    st.members.should eql([:a, :b, :c])
  end

  it "should take the block into consideration" do
    st = @observation.structure(:foo) do
      def blabla
      end
    end
    st.new.should respond_to(:blabla)
  end

  it "should allow a for_hash constructor" do
    st = @observation.structure(:foo)
    st.should respond_to(:for_hash)
  end

  it "should call the values from the hash constructor" do
    st = @observation.structure(:foo)
    item = st.for_hash(:a => 1, :b => 2, :d => :bla)
    item.a.should eql(1)
    item.b.should eql(2)
    item.c.should be_nil
  end
end
