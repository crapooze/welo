
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

observation_klass = Welo::ObservationMaker.new(Peer).structure(:default) do
  def hello
    "helo from #{uuid}"
  end
end

obs = observation_klass.for_hash(:uuid => '321', 
                           :files => [],
                           :cost => 10)

p obs
obs.hello

