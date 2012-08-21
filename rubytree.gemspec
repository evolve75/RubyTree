# -*- encoding: utf-8 -*-
#
# gemspec for the rubytree gem.
#
# Author:: Anupam Sengupta (anupamsg@gmail.com)
#
# Copyright (c) 2012 Anupam Sengupta
# All rights reserved.

$:.push File.expand_path("../lib", __FILE__)
require 'tree/version'

Gem::Specification.new do |s|
  s.name              = 'rubytree'
  s.date              = '2012-08-21'
  s.version           = Tree::VERSION
  s.license           = 'BSD'

  s.platform          = Gem::Platform::RUBY
  s.author            = 'Anupam Sengupta'
  s.email             = 'anupamsg@gmail.com'
  s.homepage          = 'http://rubytree.rubyforge.org'
  s.rubyforge_project = 'rubytree'

  s.summary           = %q{A generic tree data structure.}
  s.description       = <<-EOF
    RubyTree is a Ruby implementation of the generic tree data structure.
    It provides a node-based model to store uniquely identifiable node-elements in
    the tree and simple APIs to access, modify and traverse the structure.
    RubyTree is node-centric, where individual nodes on the tree are the primary
    compositional and structural elements.

    This implementation also mixes in the Enumerable module to allow standard
    access to the tree as a collection.
  EOF

  s.files            = Dir['lib/**/*.rb']  # The actual code
  s.files           += Dir['[A-Z]*']       # Various documentation files
  s.files           += Dir['test/**/*.rb'] # Test cases
  s.files           += ['.dir-locals.el']  # Emacs configurations

  s.require_paths    = ['lib']

  s.test_files       = Dir.glob('test/**/test_*.rb')

  s.extra_rdoc_files = ['README.rdoc', 'COPYING.rdoc', 'API-CHANGES.rdoc', 'History.txt']
  s.rdoc_options     = ["--title", "Rubytree Documentation", "--quiet"]

  s.add_runtime_dependency 'structured_warnings' , '>= 0.1.3'
  s.add_runtime_dependency 'json'                , '>= 1.7.5'

  s.add_development_dependency 'rake'      , '~> 3.0'
  s.add_development_dependency 'yard'      , '>= 0.8.2.1'
  s.add_development_dependency 'rtagstask' , '>= 0.0.4'
  s.add_development_dependency 'rcov'      , '>= 1.0.0'

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
