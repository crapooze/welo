
require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'welo/core/relationship'

describe "Relationship" do
  it "should remember the sym" do
    rel = Relationship.new(:foo, '', [''])
    rel.sym.should equal(:foo)
  end

  it "should remember the klass" do
    rel = Relationship.new('', :foo, [''])
    rel.klass.should equal(:foo)
  end

  it "should remember one kind" do
    rel = Relationship.new('', '', [:foo])
    rel.kinds.should eql([:foo])
  end
end

describe "a 'many' Relationship, with several kinds" do
  before(:each) do
    @rel = Relationship.new('', '', [:a, :b, :many, :foo, :bar])
  end

  it "should remember many kinds" do
    @rel.kinds.should eql([:a, :b, :many, :foo, :bar])
  end

  it "should be a many? relationship" do
    @rel.many?.should be_true
  end

  it "should not be a one? relationship" do
    @rel.one?.should be_false
  end
end

describe "a 'one' Relationship, with several kinds" do
  before(:each) do
    @rel = Relationship.new('', '', [:a, :b, :one, :foo, :bar])
  end

  it "should remember all kinds" do
    @rel.kinds.should eql([:a, :b, :one, :foo, :bar])
  end

  it "should not be a many? relationship" do
    @rel.many?.should be_false
  end

  it "should be a one? relationship" do
    @rel.one?.should be_true
  end
end

describe "Relationship, incompatible kinds" do
  it "should raise an error" do
    lambda { Relationship.new('','',:one, :many)}.should raise_error(ArgumentError)
  end
end
