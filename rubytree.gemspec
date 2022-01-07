#
# gemspec for the rubytree gem.
#
# Author:: Anupam Sengupta (anupamsg@gmail.com)
#
# Copyright (c) 2012, 2013, 2014, 2015, 2017, 2020, 2021 Anupam Sengupta
# All rights reserved.

require './lib/tree/version'

Gem::Specification.new do |s|
  s.name                  = 'rubytree'
  s.date                  = '2021-12-29'
  s.version               = Tree::VERSION
  s.license               = 'BSD-3-Clause-Clear'

  s.platform              = Gem::Platform::RUBY
  s.author                = 'Anupam Sengupta'
  s.email                 = 'anupamsg@gmail.com'
  s.homepage              = 'http://rubytree.anupamsg.me'

  s.required_ruby_version = '>=2.7'

  s.summary               = 'A generic tree data structure.'
  s.description           = <<-END_OF_TEXT

    RubyTree is a pure Ruby implementation of the generic tree data structure. It
    provides a node-based model to store named nodes in the tree, and provides
    simple APIs to access, modify and traverse the structure.

    The implementation is node-centric, where individual nodes in the tree are the
    primary structural elements. All common tree-traversal methods (pre-order,
    post-order, and breadth-first) are supported.

    The library mixes in the Enumerable and Comparable modules to allow access to
    the tree as a standard collection (iteration, comparison, etc.).

    A Binary tree is also provided, which provides the in-order traversal in
    addition to the other methods.

    RubyTree supports importing from, and exporting to JSON, and also supports the
    Ruby's standard object marshaling.

    This is a BSD licensed open source project, and is hosted at
    http://github.com/evolve75/RubyTree, and is available as a standard gem from
    http://rubygems.org/gems/rubytree.

    The home page for RubyTree is at http://rubytree.anupamsg.me.

  END_OF_TEXT

  s.files                = Dir['lib/**/*.rb']  # The actual code
  s.files               += Dir['[A-Z]*']       # Various documentation files
  s.files               += Dir['test/**/*.rb'] # Test cases
  s.files               += Dir['spec/**/*.rb'] # Rspec Test cases
  s.files               += Dir['examples/**/*.rb'] # Examples

  s.files               += ['.gemtest'] # Support for gem-test

  s.require_paths        = ['lib']

  s.test_files           = Dir.glob('test/**/test_*.rb')

  s.extra_rdoc_files     = %w[README.md LICENSE.md API-CHANGES.rdoc History.rdoc]
  s.rdoc_options         = ['--title', 'Rubytree Documentation', '--quiet']

  s.add_runtime_dependency 'json', '~> 2.6.1'
  s.add_runtime_dependency 'structured_warnings', '~> 0.4.0'

  # Development dependencies.
  s.add_development_dependency 'bundler', '~> 2.3.4'
  s.add_development_dependency 'coveralls', '>= 0.8.23'
  s.add_development_dependency 'rake', '>= 13.0.6'
  s.add_development_dependency 'rdoc', '>= 6.4.0'
  s.add_development_dependency 'rspec', '~> 3.10.0'
  s.add_development_dependency 'rtagstask', '~> 0.0.4'
  s.add_development_dependency 'rubocop', '>= 1.24.0'
  s.add_development_dependency 'test-unit', '>= 3.5.3'
  s.add_development_dependency 'yard', '~> 0.9.27'

  s.post_install_message = <<-END_OF_TEXT
    ========================================================================
                    Thank you for installing RubyTree.

    Note:: As of 1.0.1, RubyTree can only support MRI Ruby >= 2.7.x

    Details of the API changes are documented in the API-CHANGES file.
    ========================================================================
  END_OF_TEXT
end
