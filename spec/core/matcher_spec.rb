require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'welo/core/matcher'

describe IdentifyingMatcher, 'real world instances' do
  before :each do
    @klass = Class.new do
      include Resource
      def self.name
        "klass"
      end
      perspective :foo, [:bar, :baz]
      relationship :foo, :bar, :baz
      identify :abc, :foo, :bar, :baz
      attr_accessor :foo, :bar, :baz
    end
    @obj = @klass.new
    @obj.foo = 'foo'
    @obj.bar = 'bar'
    @obj.baz = 'baz'
  end

  it "should match parameters" do
    params = {
      'foo' => 'foo', 
      'bar' => 'bar', 
      'baz' => 'baz'
    }
    IdentifyingMatcher.new(params).match?(@obj, :abc).should be_true
  end

  it "should match prefixed parameters with a dot" do
    params = {
      'abc.foo' => 'foo', 
      'abc.bar' => 'bar', 
      'abc.baz' => 'baz'
    }
    IdentifyingMatcher.new(params, 'abc.').match?(@obj, :abc).should be_true
  end

  it "should match prefixed parameters with other signs" do
    params = {
      'abc=foo' => 'foo', 
      'abc=bar' => 'bar', 
      'abc=baz' => 'baz'
    }
    IdentifyingMatcher.new(params, 'abc=').match?(@obj, :abc).should be_true
  end


  it "should not match wrong parameters" do
    params = {:foo => :BOO, :bar => :BOO, :baz => :BOO}
    IdentifyingMatcher.new(params).match?(@obj, :abc).should be_false
  end

  it "should not match incomplete parameters" do
    params = {
      'bar' => 'bar', 
      'baz' => 'baz'
    }
    IdentifyingMatcher.new(params).match?(@obj, :abc).should be_false
  end

  it "should not match too many parameters" do
    params = {
      'foo' => 'foo', 
      'bar' => 'bar', 
      'baz' => 'baz',
      :machin => 'broken',
    }
    IdentifyingMatcher.new(params).match?(@obj, :abc).should be_false
  end

  it "should filter-out parameters when there is a prefix" do
    params = {
      'abc.foo' => 'foo', 
      'abc.bar' => 'bar', 
      'abc.baz' => 'baz',
      'machin' => 'filtered-out',
    }
    IdentifyingMatcher.new(params, 'abc.').match?(@obj, :abc).should be_true
  end

  it "should say it misses params" do
    params = {
      'bar' => 'bar', 
      'baz' => 'baz'
    }
    IdentifyingMatcher.new(params).missing_params?(@obj, :abc).should be_true
  end

  it "should say it has too many params" do
    params = {
      'bar' => 'bar', 
      'baz' => 'baz',
      'bla' => 'bla'
    }
    IdentifyingMatcher.new(params).too_many_params?(@obj, :abc).should be_true
  end
  it "should not match too many parameters" do
    params = {
      'foo' => 'foo', 
      'bar' => 'bar', 
      'baz' => 'baz',
      :machin => 'broken',
    }
    IdentifyingMatcher.new(params).match?(@obj, :abc).should be_false
  end
end


describe EpithetMatcher, 'real world instances' do
  before :each do
    @klass = Class.new do
      include Resource
      def self.name
        "klass"
      end
      epithet :other, :other_foo, :other_bar, :other_baz
      attr_accessor :foo, :bar, :baz
      def other_foo(other)
        other.foo
      end
      def other_bar(other)
        other.bar
      end
      def other_baz(other)
        other.baz
      end
    end
    @obj = @klass.new
    @obj.foo = 'foo'
    @obj.bar = 'bar'
    @obj.baz = 'baz'
  end

  it "should match parameters" do
    params = {
      'other_foo' => 'foo', 
      'other_bar' => 'bar', 
      'other_baz' => 'baz'
    }
    EpithetMatcher.new(params).match?(@klass.new, @obj, :other).should be_true
  end
end
