
require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'welo/core/observation'
require 'welo/core/resource'

describe ObservationStruct, "creating new struct (i.e. classes)" do
  before :each do
    @klass = ObservationStruct.new(:foo)
  end

  it "should respond to new_for_resource_in_perspective" do
    ObservationStruct.should respond_to(:new_for_resource_in_perspective)
  end

  it "should be a class" do
    @klass.should be_a(Class)
  end

  it "should not give new_for_resource_in_perspective to its siblings classes" do
    @klass.should_not respond_to(:new_for_resource_in_perspective)
  end

  it "should have a resource and a perspectie" do
    [:resource, :resource=, :perspective, :perspective=].each do |sym|
      @klass.should respond_to(sym)
    end
  end

end

describe ObservationStruct, "instances" do
  before :each do
    @klass = ObservationStruct.new(:foo)
    @obj = @klass.new(:bar)
  end

  it "should have a source" do
    [:source, :_source_=, :_source_].each do |sym|
      @obj.should respond_to(sym)
    end
  end
end

describe ObservationStruct, "integrated with resources" do
  pending
end
