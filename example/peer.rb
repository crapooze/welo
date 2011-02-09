
require 'welo'

class MyFile
  include Welo::Resource
  attr_accessor :name, :sha1
  identify :default, :sha1
  relationship :peers, :Peer, :many
  perspective :default, [:name, :sha1]
  def initialize(name)
    @name = name
    @sha1 = name.sum #stub in place for an actual SHA1
  end
end

class Peer
  include Welo::Resource
  attr_accessor :name, :peers, :cost, :files, :ipaddr
  identify :default, :name
  identify :peer, :ipaddr
  relationship :peers, :Peer, :many
  relationship :files, :MyFile, :many
  relationship :preferred_files, :MyFile, :many, :alias
  epithet :preferred_files, 
    :index_for_preffered_file, :scrambled_name_for_preffered_file
  nesting :peers, :peer
  perspective :default, [:name, :uuid, :peers, :files, :preferred_files, :cost]

  def initialize(name)
    @name = name
    @ipaddr = "10.0.0.#{name.length}"
    @files = []
    @peers = []
    @cost = rand(100)
  end

  def index_for_preffered_file(f)
    preferred_files.index(f)
  end

  def scrambled_name_for_preffered_file(f)
    f.name.reverse
  end

  def preferred_files
    @preferred_files ||= files.sort_by(&:name)
  end
end

Files = %w{abc def ghi jkl}.map{|n| MyFile.new(n)}
Peers = %w{foo _bar __baz}.map{|n| Peer.new(n)}

