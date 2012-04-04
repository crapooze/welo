
require 'rubygems'
require 'rake/gempackagetask'

$LOAD_PATH.unshift('lib')
require 'welo'

spec = Gem::Specification.new do |s|
        s.name = 'welo'
        s.rubyforge_project = 'welo'
        s.version = Welo::VERSION
        s.author = Welo::AUTHORS.first
        s.homepage = Welo::WEBSITE
        s.summary = "A light resource model for Ruby"
        s.email = "crapooze@gmail.com"
        s.platform = Gem::Platform::RUBY

        s.files = [
          'Rakefile', 
          'TODO', 
          'README',
          'lib/welo.rb',
          'lib/welo/core/resource.rb',
          'lib/welo/core/relationship.rb',
          'lib/welo/core/link.rb',
          'lib/welo/core/matcher.rb',
          'lib/welo/core/nesting.rb',
          'lib/welo/core/embedding.rb',
          'lib/welo/core/embedder.rb',
          'lib/welo/core/perspective.rb',
          'lib/welo/base/resource.rb',
        ]

        s.require_path = 'lib'
        s.bindir = 'bin'
        s.executables = []
        s.has_rdoc = true
end

Rake::GemPackageTask.new(spec) do |pkg|
        pkg.need_tar = true
end

task :gem => ["pkg/#{spec.name}-#{spec.version}.gem"] do
        puts "generated #{spec.version}"
end

