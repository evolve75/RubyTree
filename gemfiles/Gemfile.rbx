source 'https://rubygems.org'

# Specify your gem's dependencies in rubytree.gemspec
gemspec :path => '..'

platforms :rbx do
  gem "rubysl", "~> 2.1"
  gem "rubysl-test-unit", "~> 2.1"
end

group :development, :test do
  gem "rake", "~> 10.1"
end

# Local Variables:
# mode: ruby
# End:
