# -*- encoding: utf-8 -*-
#
# gemspec for the rubytree gem.
#
# Author:: Anupam Sengupta (anupamsg@gmail.com)
#
# Copyright (c) 2012, 2013, 2014, 2015, 2017, 2020 Anupam Sengupta
# All rights reserved.

require './lib/tree/version'

Gem::Specification.new do |s|
  s.name                  = 'rubytree'
  s.date                  = '2021-03-01'
  s.version               = Tree::VERSION
  s.license               = 'BSD-3-Clause-Clear'

  s.platform              = Gem::Platform::RUBY
  s.author                = 'Anupam Sengupta'
  s.email                 = 'anupamsg@gmail.com'
  s.homepage              = 'http://rubytree.anupamsg.me'

  s.required_ruby_version = '>=2.5'

  s.summary               = %q{A generic tree data structure.}
  s.description           = <<-EOF

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

  EOF

  s.files                = Dir['lib/**/*.rb']  # The actual code
  s.files               += Dir['[A-Z]*']       # Various documentation files
  s.files               += Dir['test/**/*.rb'] # Test cases
  s.files               += Dir['spec/**/*.rb'] # Rspec Test cases
  s.files               += Dir['examples/**/*.rb'] # Examples

  s.files               += ['.gemtest']        # Support for gem-test

  s.require_paths        = ['lib']

  s.test_files           = Dir.glob('test/**/test_*.rb')

  s.extra_rdoc_files     = %w(README.md LICENSE.md API-CHANGES.rdoc History.rdoc)
  s.rdoc_options         = ['--title', 'Rubytree Documentation', '--quiet']

  s.add_runtime_dependency 'structured_warnings' , '~> 0.4.0'
  s.add_runtime_dependency 'json'                , '~> 2.3.0' # erlaube kompatibility mit Keycloak 3.2.1 gem

  # Note: Rake is added as a development and test dependency in the Gemfile.
  s.add_development_dependency 'bundler'         , '~> 2.1.4'
  s.add_development_dependency 'rdoc'            , '~> 6.2.1'
  s.add_development_dependency 'yard'            , '~> 0.9.25'
  s.add_development_dependency 'rtagstask'       , '~> 0.0.4'
  s.add_development_dependency 'rspec'           , '~> 3.9.0'

  s.post_install_message = <<-EOF
    ========================================================================
                    Thank you for installing RubyTree.

    Note:: As of 1.0.0, RubyTree can only support MRI Ruby >= 2.2.x

    Details of the API changes are documented in the API-CHANGES file.
    ========================================================================
  EOF

end
