#
# gemspec for the rubytree gem.
#
# Author:: Anupam Sengupta (anupamsg@gmail.com)
#
# Copyright (c) 2012-2026 Anupam Sengupta. All rights reserved.
#
# frozen_string_literal: true

require File.join(__dir__, '/lib/tree/version')

Gem::Specification.new do |s|
  s.name                  = 'rubytree'
  s.version               = Tree::VERSION
  s.license               = 'BSD-2-Clause'
  # NOTE: s.date should NOT be assigned. It is automatically set to pkg date.
  s.platform              = Gem::Platform::RUBY
  s.author                = 'Anupam Sengupta'
  s.email                 = 'anupamsg@gmail.com'
  s.homepage              = 'http://rubytree.anupamsg.me'

  s.required_ruby_version = '>=3.1'

  s.summary               = 'A generic tree data structure for Ruby.'

  s.description           = <<-END_DESC

    RubyTree is a Ruby implementation of the generic tree data structure. It
    provides simple APIs to store named nodes, and to access, modify, and
    traverse the tree.

    The data model is node-centric, where nodes in the tree are the primary
    structural elements. It supports all common tree-traversal methods (pre-order,
    post-order, and breadth first).

    RubyTree mixes in the Enumerable and Comparable modules and behaves like a
    standard Ruby collection (iteration, comparison, etc.).

    RubyTree also includes a binary tree implementation, which provides in-order
    node traversal besides the other methods.

    RubyTree can import from and export to JSON, and supports Ruby’s object
    marshaling.
  END_DESC

  s.metadata = {
    'rubygems_mfa_required' => 'true',
    'github_repo' => 'https://github.com/evolve75/RubyTree',
    'source_code_uri' => 'https://github.com/evolve75/RubyTree',
    'changelog_uri' => 'https://github.com/evolve75/RubyTree/blob/master/CHANGELOG.md'
  }

  s.files                = Dir['lib/**/*.rb']  # The actual code
  s.files               += Dir['[A-Z]*'].select { |path| File.file?(path) } # Various documentation files
  s.files               += Dir['test/**/*.rb'] # Test cases
  s.files               += Dir['spec/**/*.rb'] # Rspec Test cases
  s.files               += Dir['examples/**/*.rb'] # Examples

  # @todo: Check if this is really needed.
  s.files               += ['.gemtest'] # Support for gem-test

  s.require_paths        = ['lib']

  s.extra_rdoc_files     = %w[README.md LICENSE.md CHANGELOG.md]
  s.rdoc_options         = ['--title', "Rubytree Documentation: #{s.name}-#{s.version}",
                            '--main', 'README.md',
                            '--quiet']

  s.add_dependency 'json', '~> 2.18'

  # NOTE: Rake is added as a development and test dependency in the Gemfile.
  s.add_development_dependency 'bundler', '~> 2.6'
  s.add_development_dependency 'rake', '~> 13.3'
  s.add_development_dependency 'rdoc', '~> 7.1'
  s.add_development_dependency 'rspec', '~> 3.13'
  s.add_development_dependency 'rtagstask', '~> 0.0'
  s.add_development_dependency 'rubocop', '~> 1.84'
  s.add_development_dependency 'rubocop-rake', '~> 0.7'
  s.add_development_dependency 'rubocop-rspec', '~> 3.0'
  s.add_development_dependency 'simplecov', '~> 0.22'
  s.add_development_dependency 'simplecov-lcov', '~> 0.9'
  s.add_development_dependency 'test-unit', '~> 3.7'
  s.add_development_dependency 'yard', '~> 0.9'

  s.post_install_message = <<-END_MESSAGE
    ========================================================================
                    Thank you for installing RubyTree.

    Note::

    - 3.0.0pre sets the minimum Ruby version to 3.1.

    - 2.2.0 is a minor update that improves tree integrity checks,
            traversal robustness, and node management edge cases.

    - 2.1.1 is a minor update that updates all dependencies and
            Updates the guard clause for creating a tree from a hash.

    - 2.1.0 is a minor update that brings all libraries to their
            latest stable versions. This version no longer supports
            Ruby 2.6 (minimum requirement is now >= 2.7).

    - 2.0.0 is a major release with BREAKING API changes.
            See `CHANGELOG.md` for details.

    - For the full release history and API change notes, see `CHANGELOG.md`.

    ========================================================================
  END_MESSAGE
end
