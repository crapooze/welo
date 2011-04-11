
$LOAD_PATH << './lib'
require './example/peer'
require 'yaml'
require 'welo'

a, b, c, d = * Files
foo, bar, baz = *Peers
foo.peers << bar
foo.peers << baz
bar.peers << foo
foo.files << a
foo.files << b
class Peer
  perspective :other_peer, [:uuid, :files, :cost]
end

RubyObjectSource = Struct.new(:item) do
  def observe
    yield item
  end
end

observation_klass = Welo::ObservationStruct.new_for_resource_in_perspective(Peer, :default) do
  def hello
    "helo from #{uuid}"
  end
end

observer = Welo::Observer.new

observer.register(:observation) do |o|
  # the observation (a struct's instance with the fields
  # corresponding to the observed resource/perspective
  p o

  # some meta-data on this observation
  p o.class.resource
  p o.class.perspective
  p o.source

  # the added methods to this observation
  p o.hello
end

h = {'uuid' => '321', 'files' => ['/myfile/103'], 'cost' => 10 }

observer.observe_source(RubyObjectSource.new(h), observation_klass)
