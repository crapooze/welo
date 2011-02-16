
$LOAD_PATH << './lib'
require './example/peer'
require 'yaml'

a, b, c, d = * Files
foo, bar, baz = *Peers
foo.peers << bar
foo.peers << baz
bar.peers << foo
foo.files << a
foo.files << b

puts foo.to_YAML(:default)
puts 

puts foo.to_text(:default)
puts

puts a.to_text(:default)
puts

puts a.to_YAML(:default)
puts

begin
  require 'json'
  puts foo.to_json(:default)
  puts

  puts a.to_json(:default)
  puts
rescue LoadError
  puts "no json example, install json if you want"
end

peer = foo.peers.find do |pe|
  pe.match_params?({'ipaddr' => '10.0.0.5'}, :peer)
end

p peer

file =  foo.preferred_files.find do |f|
 foo.epithet_resource_match_params?(f, 
     {'index_for_preffered_file' => 0,
       'scrambled_name_for_preffered_file' => 'cba'},
    :preferred_files)
end

p file
