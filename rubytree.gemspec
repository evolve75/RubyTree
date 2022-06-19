#
# gemspec for the rubytree gem.
#
# Author:: Anupam Sengupta (anupamsg@gmail.com)
#
# Copyright (c) 2012-2022 Anupam Sengupta. All rights reserved.

require './lib/tree/version'

Gem::Specification.new do |s|
  s.name                  = 'rubytree'
  s.date                  = '2022-06-21'
  s.version               = Tree::VERSION
  s.license               = 'BSD-3-Clause-Clear'

  s.platform              = Gem::Platform::RUBY
  s.author                = 'Anupam Sengupta'
  s.email                 = 'anupamsg@gmail.com'
  s.homepage              = 'http://rubytree.anupamsg.me'

  s.required_ruby_version = '>=2.6'

  s.summary               = 'A generic tree data structure.'
  # @todo: Check if this can be formatted in Markdown or RD.
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

  # @todo: Check if this is really needed.
  s.files               += ['.gemtest'] # Support for gem-test

  s.require_paths        = ['lib']

  s.test_files           = Dir.glob('test/**/test_*.rb')

  s.extra_rdoc_files     = %w[README.md LICENSE.md API-CHANGES.rdoc History.rdoc]
  s.rdoc_options         = ['--title', 'Rubytree Documentation', '--quiet']

  s.add_runtime_dependency 'json', '> 2.3.1'

  # Note: Rake is added as a development and test dependency in the Gemfile.
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'rtagstask'
  s.add_development_dependency 'rspec'
  s.add_development_dependency "rake"
  s.add_development_dependency "test-unit"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "rubocop-rake"
  s.add_development_dependency "rubocop-rspec"

  s.post_install_message = <<-EOF
    ========================================================================
                    Thank you for installing RubyTree.

    Note::

    - 2.0.0 is a major release with BREAKING API changes.
            See `API-CHANGES.rdoc` for details.

    - `Tree::TreeNode#depth` method has been removed (it was broken).

    - Support for `CamelCase` methods names has bee removed.

    - Use of integers as node names does not require the optional
      `num_as_name` flag.

    - `structured_warnings` is no longer a dependency.

    - Explicit support for rbx Ruby has been removed.

    ========================================================================
  EOF
end
