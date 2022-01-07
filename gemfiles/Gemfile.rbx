source 'https://rubygems.org'

# Specify your gem's dependencies in rubytree.gemspec
gemspec path: '..'

platforms :rbx do
  gem 'rubysl'
  gem 'rubysl-test-unit'
end

group :development, :test do
  gem 'rake', '~> 10.1'
end

# Local Variables:
# mode: ruby
# End:
