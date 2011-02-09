
require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'welo/core/link'

describe Link, 'simple initialization' do
  it "sohuld remember the pointing and pointed item" do
    Link.new(:abc, :foo).from.should equal(:abc)
    Link.new(:abc, :foo).to.should equal(:foo)
  end

  it "should give the default absolute path from the pointed resource" do
    st1 = Struct.new(:_path) do
      def path(arg)
        _path
      end
    end
    to = st1.new(:foo)
    st2 = Struct.new(:_path) do
      def nesting(arg)
        nil
      end
    end
    from = st2.new(:bar)
    Link.new(from, to).to_s.should eql('/foo')
  end

  it "should be lazy by default" do
    Link.new(:abc, :foo).should be_lazy
  end

  it "should not be lazy when told so" do
    Link.new(:abc, :foo, :lazy => false).should_not be_lazy
  end

end

describe Link, 'which are lazy' do
  it "should not call lambdas if there's a :to value already" do
    test_error = Class.new(StandardError)
    l = Link.new(:abc, :foo) do
      raise test_error.new
    end
    lambda { l.to }.should_not raise_error(test_error)
  end

  it "should call the lambda only when needed" do
    test_error = Class.new(StandardError)
    l = Link.new(:abc) do
      raise test_error.new
    end
    lambda { l.to }.should raise_error(test_error)
  end

  it "should call the lambda only once when needed" do
    test_error = Class.new(StandardError)
    passed = false
    l = Link.new(:abc) do
      unless passed
        passed = true
        raise test_error.new 
      end
    end
    lambda { l.to }.should raise_error(test_error)
    lambda { l.to }.should_not raise_error(test_error)
  end
end

describe Link, 'simple with nestings' do
  pending "real world example"
end

describe LinksEnumerator do
  it "should remember the enumerator" do
    l = LinksEnumerator.new(:foo) do |x|
    end
    l.enum.should equal(:foo)
  end

  it "should remember the block" do
    l = LinksEnumerator.new do |x|
    end
    l.enum.should be_a(Proc)
  end

  it "should be Enumerable" do
    l = LinksEnumerator.new
    l.should be_a(Enumerable)
  end

  it "should call the proc" do
    l = LinksEnumerator.new do |&blk|
      2.times do |t| 
        blk.call(t)
      end
    end
    l.to_a.should eql([0, 1])
  end

  it "should call the enum method" do
    l = LinksEnumerator.new((0 .. 3))
    l.to_a.should eql([0, 1, 2, 3])
  end
end
