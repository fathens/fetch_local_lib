require 'fetch_local_lib/version'

Gem::Specification.new do |s|
    s.platform    = Gem::Platform::RUBY
    s.name        = "fetch_local_lib"
    s.version     = FetchLocalLib::VERSION
    s.summary     = "Library to fetch local library from git"

    s.required_ruby_version = ">= 2.3.1"

    s.license = "MIT"

    s.author   = "Office f:athens"
    s.email    = "devel@fathens.org"
    s.homepage = "http://fathens.org"

    s.files        = Dir["lib/**/*"]

    s.add_runtime_dependency 'git'
end
