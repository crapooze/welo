
require File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'welo/core/perspective'

describe Perspective, 'a way at looking at things' do
  it "should have a name and fields" do
    persp = Perspective.new(:a, :b,:c)
    persp.name.should eql(:a)
    persp.fields.should eql([:b, :c])
  end
end
