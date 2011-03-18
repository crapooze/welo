
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

observation_klass = Welo::ObservationStruct.new_for_resource_in_perspective(Peer, :default) do
  def hello
    "helo from #{uuid}"
  end
end

class DummyObserver < Welo::Observer
end
RubyObjectSource = Struct.new(:observe)

observer = DummyObserver.new([Peer])

observer.register(:observation) do |o|
  p o
  p o.hello
end

h = {'uuid' => '321', 'files' => [], 'cost' => 10 }

observer.observe_source(RubyObjectSource.new(h), observation_klass)
