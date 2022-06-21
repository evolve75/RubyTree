#
# gemspec for the rubytree gem.
#
# Author:: Anupam Sengupta (anupamsg@gmail.com)
#
# Copyright (c) 2012-2022 Anupam Sengupta. All rights reserved.
#
# frozen_string_literal: true

require './lib/tree/version'

Gem::Specification.new do |s|
  s.name                  = 'rubytree'
  s.version               = Tree::VERSION
  s.license               = 'BSD-3-Clause-Clear'
  # NOTE: s.date should NOT be assigned. It is automatically set to pkg date.
  s.platform              = Gem::Platform::RUBY
  s.author                = 'Anupam Sengupta'
  s.email                 = 'anupamsg@gmail.com'
  s.homepage              = 'http://rubytree.anupamsg.me'

  s.required_ruby_version = '>=2.6'

  s.summary               = 'A generic tree data structure for Ruby.'

  s.description           = <<-END_DESC
    RubyTree is a pure Ruby implementation of the generic tree data
    structure. It provides a node-based model to store named nodes in the tree,
    and provides simple APIs to access, modify and traverse the structure.

    The implementation is node-centric, where individual nodes in the tree are
    the primary structural elements. All common tree-traversal methods
    (pre-order, post-order, and breadth-first) are supported.

    The library mixes in the Enumerable and Comparable modules to allow access
    to the tree as a standard collection (iteration, comparison, etc.).

    A Binary tree is also provided, which provides the in-order traversal in
    addition to the other methods.

    RubyTree supports importing from, and exporting to JSON, and also supports
    the Ruby's standard object marshaling.

    This is a BSD licensed open source project, and is hosted at
    <https://github.com/evolve75/RubyTree>, and is available as a standard gem
    from <https://rubygems.org/gems/rubytree>.

    The home page for RubyTree is at <http://rubytree.anupamsg.me>.

  END_DESC

  s.metadata = {
    'rubygems_mfa_required' => 'true'
  }

  s.files                = Dir['lib/**/*.rb']  # The actual code
  s.files               += Dir['[A-Z]*']       # Various documentation files
  s.files               += Dir['test/**/*.rb'] # Test cases
  s.files               += Dir['spec/**/*.rb'] # Rspec Test cases
  s.files               += Dir['examples/**/*.rb'] # Examples

  # @todo: Check if this is really needed.
  s.files               += ['.gemtest'] # Support for gem-test

  s.require_paths        = ['lib']

  s.test_files           = Dir.glob('test/**/test_*.rb')

  s.extra_rdoc_files     = %w[README.md LICENSE.md API-CHANGES.md History.md]
  s.rdoc_options         = ['--title', "Rubytree Documentation: #{s.name}-#{s.version}",
                            '--main', 'README.md',
                            '--quiet']

  s.add_runtime_dependency 'json', '~> 2.0', '> 2.3.1'

  # NOTE: Rake is added as a development and test dependency in the Gemfile.
  s.add_development_dependency 'bundler', '~> 2.3'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rdoc', '~> 6.0'
  s.add_development_dependency 'rspec', '~> 3.0', '> 3.10'
  s.add_development_dependency 'rtagstask', '~> 0.0.4'
  s.add_development_dependency 'rubocop', '~> 1.0'
  s.add_development_dependency 'rubocop-rake', '~> 0.0'
  s.add_development_dependency 'rubocop-rspec', '~> 2.0'
  s.add_development_dependency 'test-unit', '~> 3.0'
  s.add_development_dependency 'yard', '~> 0.0', '> 0.9'

  s.post_install_message = <<-END_MESSAGE
    ========================================================================
                    Thank you for installing RubyTree.

    Note::

    - 2.0.0 is a major release with BREAKING API changes.
            See `API-CHANGES.md` for details.

    - `Tree::TreeNode#depth` method has been removed (it was broken).

    - Support for `CamelCase` methods names has bee removed.

    - Use of integers as node names does not require the optional
      `num_as_name` flag.

    - `structured_warnings` is no longer a dependency.

    - Explicit support for rbx Ruby has been removed.

    ========================================================================
  END_MESSAGE
end
