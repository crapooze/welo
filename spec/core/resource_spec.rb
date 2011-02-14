
require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'welo/core/link'

describe Resource, 'class initialization' do
  before :each do
    @klass = Class.new do
      include Resource
      def self.name
        "klass"
      end
    end
  end

  it "should have an URL base name" do
    @klass.base_path.should eql('klass')
  end

  it "should have :uuid as unique, default identifiers" do
    @klass.identify(:default).should eql([:uuid])
    @klass.identifiers(:default).should eql(['uuid'])
  end

  it "should have no relationships" do
    @klass.relationships.should be_empty
  end

  it "should have no perspectives" do
    @klass.perspectives.should be_empty
  end

  it "should have no nestings" do
    @klass.nestings.should be_empty
  end
end

describe Resource, 'class modifications' do
  before :each do
    @klass = Class.new do
      include Resource
      def self.name
        "klass"
      end
    end
  end

  it "should record the URL base name" do
    @klass.base_path 'foo'
    @klass.base_path.should eql('foo')
  end

  it "should record the identifiers with label" do
    @klass.identify :abc, [:foo, :bar]
    @klass.identify(:abc).should eql([:foo, :bar])
  end

  it "should record the perspectives" do
    @klass.perspective(:foo, [:bar, :baz])
    @klass.perspective(:foo).fields.should eql([:bar, :baz])
  end

  it "should record the relationships" do
    @klass.relationship(:foo, [:bar, :baz])
    @klass.relationship(:foo).should_not be_nil
  end

  it "should record the nestings" do
    @klass.nesting(:foo, :bar)
    @klass.nesting(:foo).should_not be_nil
  end

  it "should build the path model on the identity map" do
    @klass.identify :abc, [:foo, :bar]
    @klass.path_model(:abc).should eql('klass/:foo/:bar')
  end

  it "should build the path model and prefix the params" do
    @klass.identify :abc, [:foo, :bar]
    @klass.path_model(:abc, 'abc.').should eql('klass/:abc.foo/:abc.bar')
  end

  it "should allow empty identifiers" do
    @klass.identify :null, []
    @klass.new.path(:null).should eql('klass')
  end
end

describe Resource, 'class inheritance' do
  before :each do
    @klass = Class.new do
      include Resource
      def self.name
        "klass"
      end
      perspective :foo, [:bar, :baz]
      relationship :foo, :bar, [:baz]
      nesting :foo, :bar
      identify :abc, [:foo, :bar, :baz]
    end
  end
  
  it "should copy the base name" do
    klass2 = Class.new(@klass)
    klass2.base_path.should eql('klass')
  end

  it "should copy the identification" do
    klass2 = Class.new(@klass)
    klass2.identify(:abc).should eql([:foo, :bar, :baz])
  end

  it "should copy the perspectives" do
    klass2 = Class.new(@klass)
    klass2.perspective(:foo).should_not be_nil
  end

  it "should copy the relationships" do
    klass2 = Class.new(@klass)
    klass2.relationship(:foo).should_not be_nil
  end

  it "should copy the nestings" do
    klass2 = Class.new(@klass)
    klass2.nesting(:foo).should_not be_nil
  end
end

describe Resource, 'default instances' do
  before :each do
    klass = Class.new do
      include Resource
    end
    @obj = klass.new
  end

  it "should have an uuid" do
    @obj.uuid.should_not be_nil
  end

  it "should records its uuid once for all" do
    uuid1 = @obj.uuid
    uuid2 = @obj.uuid
    uuid1.should equal(uuid2)
  end
end

describe Resource, 'identifying path' do
  before :each do
    @klass = Class.new do
      include Resource
      def self.name
        "klass"
      end
      identify :bla, [:foo, :bar, :baz]
      attr_accessor :foo, :bar, :baz
    end
    @obj = @klass.new
    @obj.foo = 'abc'
    @obj.bar = 'def'
    @obj.baz = 'ghi'
  end

  it "should" do
    @obj.identifying_path_part(:bla).should eql('abc/def/ghi')
  end
end

describe Resource, 'real world instances matching' do
  before :each do
    @klass = Class.new do
      include Resource
      def self.name
        "klass"
      end
      perspective :foo, [:bar, :baz]
      relationship :foo, :bar, [:baz]
      identify :abc, [:foo, :bar, :baz]
      attr_accessor :foo, :bar, :baz
    end
    @obj = @klass.new
    @obj.foo = 'foo'
    @obj.bar = 'bar'
    @obj.baz = 'baz'
  end

  it "should have a base from the class" do
    @obj.base_path.should eql('klass')
  end

  it "should have the identifiers from the class" do
    @obj.identify(:abc).should eql([:foo, :bar, :baz])
  end

  it "should have its own path, with the identifiers" do
    @obj.path(:abc).should eql('klass/foo/bar/baz')
  end

  it "should match parameters" do
    params = {
      'foo' => 'foo', 
      'bar' => 'bar', 
      'baz' => 'baz'
    }
    @obj.match_params?(params, :abc).should be_true
  end

  it "should match prefixed parameters" do
    params = {
      'abc.foo' => 'foo', 
      'abc.bar' => 'bar', 
      'abc.baz' => 'baz'
    }
    @obj.match_params?(params, :abc, 'abc.').should be_true
  end

  it "should not match wrong parameters" do
    params = {:foo => :BOO, :bar => :BOO, :baz => :BOO}
    @obj.match_params?(params, :abc).should be_false
  end

  it "should not match incomplete parameters" do
    params = {
      'bar' => 'bar', 
      'baz' => 'baz'
    }
    @obj.match_params?(params, :abc).should be_false
  end

  it "should not match too many parameters" do
    params = {
      'foo' => 'foo', 
      'bar' => 'bar', 
      'baz' => 'baz',
      :machin => 'broken',
    }
    @obj.match_params?(params, :abc).should be_false
  end
end

describe Resource, 'structuring' do
  before :each do
    @klass = Class.new do
      include Resource
      base_path 'test'
      relationship :foo, :baz, [:one]
      relationship :bar, :bar, [:many]
      relationship :broken, :baz, [:really, :broken]
      perspective :perspective, [:foo, :bar, :baz]
      perspective :broken, [:broken]
      attr_accessor :foo, :bar, :baz
    end
    pseudo_resource = Struct.new(:path)
    @obj = @klass.new
    @obj.foo = pseudo_resource.new('pseudo/resource')
    @obj.bar = []
    @obj.baz = :baz
  end

  it "should structure itself according to the perspective" do
    struct = @klass.structure(:perspective)
    struct.should have(3).items
    struct[0].should be_a(Relationship)
    struct[1].should be_a(Relationship)
    struct[2].should equal(:baz)
  end

  it "should raise error when there's no perspective" do
    lambda{@klass.structure(:nonexistant)}.should raise_error(ArgumentError)
  end

  it "should complain about the relationship being of unknown kind" do
    rel = @obj.relationship(:broken)
    lambda {@obj.link_for_rel(rel)}.should raise_error(ArgumentError)
    lambda {@obj.structure_pairs(:broken)}.should raise_error(ArgumentError)
  end

  it "should fill its structure itself according to the relationships" do
    pairs = @obj.structure_pairs(:perspective)
    pairs.should have(3).items
    syms = pairs.transpose[0]
    vals = pairs.transpose[1]
    syms.should eql([:foo, :bar, :baz])
    vals[0].should be_a(Link)
    vals[1].should be_a(LinksEnumerator)
    vals[2].should equal(:baz)
  end
end
