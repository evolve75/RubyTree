# -*- encoding: utf-8 -*-
#
# gemspec for the rubytree gem.
#
# Author:: Anupam Sengupta (anupamsg@gmail.com)
#
# Copyright (c) 2012, 2013, 2014, 2015 Anupam Sengupta
# All rights reserved.

$:.unshift File.expand_path("../lib", __FILE__)
require "tree/version"

Gem::Specification.new do |s|
  s.name                  = 'rubytree'
  s.date                  = '2015-12-31'
  s.version               = Tree::VERSION
  s.license               = 'BSD'

  s.platform              = Gem::Platform::RUBY
  s.author                = 'Anupam Sengupta'
  s.email                 = 'anupamsg@gmail.com'
  s.homepage              = 'http://rubytree.anupamsg.me'

  s.required_ruby_version = '>=1.8.7'

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

  s.extra_rdoc_files     = ['README.md', 'LICENSE.md',
                            'API-CHANGES.rdoc', 'History.rdoc']
  s.rdoc_options         = ["--title", "Rubytree Documentation", "--quiet"]

  s.add_runtime_dependency 'structured_warnings' , '~> 0.2'
  s.add_runtime_dependency 'json'                , '~> 1.8'

  # Note: Rake is added as a development and test dependency in the Gemfile.
  s.add_development_dependency 'bundler'         , '~> 1.7'
  s.add_development_dependency 'rdoc'            , '~> 4.2'
  s.add_development_dependency 'yard'            , '~> 0.8'
  s.add_development_dependency 'rtagstask'       , '~> 0.0'
  s.add_development_dependency 'rspec'           , '~> 3.4'

  s.post_install_message = <<-EOF
    ========================================================================
                    Thank you for installing RubyTree.

    Note:: As of 0.9.5, the Tree::TreeNode#add method has 'move' semantics.

    Details of the API changes are documented in the API-CHANGES file.
    ========================================================================
  EOF

end
