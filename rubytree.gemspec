# -*- encoding: utf-8 -*-
#
# gemspec for the rubytree gem.
#
# Author:: Anupam Sengupta (anupamsg@gmail.com)
#
# Copyright (c) 2012, 2013, 2014 Anupam Sengupta
# All rights reserved.

$:.unshift File.expand_path("../lib", __FILE__)
require "tree/version"

Gem::Specification.new do |s|
  s.name                  = 'rubytree'
  s.date                  = '2014-01-03'
  s.version               = Tree::VERSION
  s.license               = 'BSD'

  s.platform              = Gem::Platform::RUBY
  s.author                = 'Anupam Sengupta'
  s.email                 = 'anupamsg@gmail.com'
  s.homepage              = 'http://rubytree.rubyforge.org'
  s.rubyforge_project     = 'rubytree'
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

    The home page for RubyTree is at http://rubytree.rubyforge.org.

  EOF

  s.files                = Dir['lib/**/*.rb']  # The actual code
  s.files               += Dir['[A-Z]*']       # Various documentation files
  s.files               += Dir['test/**/*.rb'] # Test cases
  s.files               += Dir['examples/**/*.rb'] # Examples

  s.files               += ['.gemtest']        # Support for gem-test

  s.require_paths        = ['lib']

  s.test_files           = Dir.glob('test/**/test_*.rb')

  s.extra_rdoc_files     = ['README.md', 'LICENSE.md',
                            'API-CHANGES.rdoc', 'History.rdoc']
  s.rdoc_options         = ["--title", "Rubytree Documentation", "--quiet"]

  s.add_runtime_dependency 'structured_warnings' , '~> 0.1'
  s.add_runtime_dependency 'json'                , '~> 1.8'

  s.add_development_dependency 'bundler'         , '~> 1.5'
  s.add_development_dependency 'rdoc'            , '~> 4.1'
  s.add_development_dependency 'yard'            , '~> 0.8'
  s.add_development_dependency 'rtagstask'       , '~> 0.0'

  s.post_install_message = <<-EOF
    ========================================================================
                    Thank you for installing rubytree.

    Note that the TreeNode#siblings method has changed in 0.8.3.
    It now returns an empty array for the root node.

                 WARNING: SIGNIFICANT API CHANGE in 0.8.0 !
                 ------------------------------------------

    Please note that as of 0.8.0 the CamelCase method names are DEPRECATED.
    The new method names follow the ruby_convention (separated by '_').

    The old CamelCase methods still work (a warning will be displayed),
    but may go away in the future.

    Details of the API changes are documented in the API-CHANGES file.
    ========================================================================
  EOF

end
