
require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'welo/core/observation'
require 'welo/core/resource'

describe Observer,"an almost evented observatory" do
  before :each do
    @obs = Observer.new
  end

  it "should have no registrations" do
    @obs.registrations.should be_empty
  end

  it "should register on an event" do
    @obs.register(:foo) {dummy}
    @obs.registrations.should_not be_empty
    @obs.registrations[:foo].should have(1).item
  end

  it "should register several time on same event" do
    r1 = @obs.register(:foo) {dummy}
    r2 = @obs.register(:foo) {dummy}
    @obs.registrations[:foo].should have(2).item
    r1.should_not eql(r2)
  end

  it "should be able to unregister one registration" do
    reg = @obs.register(:foo){dummy}
    @obs.registrations[:foo].should have(1).item
    @obs.unregister reg
    @obs.registrations[:foo].should be_empty
  end

  it "should unregister exactly one registration" do
    reg1 = @obs.register(:foo) {dummy}
    reg2 = @obs.register(:foo) {dummy}
    @obs.unregister reg1
    @obs.registrations[:foo].should have(1).item
    @obs.registrations[:foo].should include(reg2)
  end

  it "should mass unregister" do
    @obs.register(:foo) {dummy}
    @obs.register(:foo) {dummy}
    @obs.register(:bar) {dummy}
    @obs.unregister_all(:foo)
    @obs.registrations[:foo].should be_nil
    @obs.registrations.should_not be_empty
  end
end

describe Observer,"calling events" do
  before :each do
    @obs = Observer.new
    @myError = Class.new(StandardError)
  end

  it "should call nothing" do
    lambda { @obs.event(:foo) }.should_not raise_error
  end

  it "should call the block" do
    @obs.register(:foo) {raise @myError.new}
    lambda { @obs.event(:foo) }.should raise_error(@myError)
  end

  it "should call all the blocks in the registration order" do
    foos = []
    @obs.register(:foo) {foos << :a}
    @obs.register(:foo) {foos << :b}
    @obs.register(:bar) {foos << :c}
    @obs.event(:foo) 
    foos.should eql([:a, :b])
    @obs.event(:bar) 
    foos.should eql([:a, :b, :c])
  end
end

__END__
#FOR LATER
describe Observer,"observing something" do
  before :each do
    @obs = Observer.new
    @myError = Class.new(StandardError)
    @mySource = Class.new do
      attr_reader :observations
      def initialize(obs=[])
        @observations = obs
      end
      def observe
        observations.each {|o| yield o}
      end
    end
  end

  it "should call the :observation event" do
    @obs.register(:observation){raise @myError.new}
    src = @mySource.new([{:a => :b}])
    st = Struct.new(:a) do
      def self.for_hash(h)
        p h
      end
    end
    lambda { @obs.observe_source(src, st) }.should raise_error(@myError)
  end
end
