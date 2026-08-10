# RubyTree

[![Gem Version][gem_version_badge]][gem_version_link]
[![Gem Downloads][gem_downloads_badge]][gem_downloads_link]
![Build State][bb]
[![Coverage][c]][cl]

```text
        __       _           _
       /__\_   _| |__  _   _| |_ _ __ ___  ___
      / \// | | | '_ \| | | | __| '__/ _ \/ _ \
     / _  \ |_| | |_) | |_| | |_| | |  __/  __/
     \/ \_/\__,_|_.__/ \__, |\__|_|  \___|\___|
                      |___/
```

## Description

**RubyTree** is a pure Ruby implementation of the generic
[tree data structure][tree_data_structure]. It provides a node-based model to
store named nodes in the tree, and provides simple APIs to access, modify and
traverse the structure.

The implementation is *node-centric*, where individual nodes in the tree are
the primary structural elements. All common tree-traversal methods
([pre-order][], [post-order][], and [breadth-first][]) are supported.

The library mixes in the [Enumerable][] and [Comparable][] modules to allow
access to the tree as a standard collection (iteration, comparison, etc.).

Available tree types include:

* [Binary tree][] with [in-order][] traversal support.
* [Binary Heap][] (min-heap) under `Tree::BinaryHeapNode` (require
  `tree/binaryheap`).
* [Binary Max Heap][] under `Tree::BinaryMaxHeapNode` (require
  `tree/binarymaxheap`).
* [Fenwick Tree][] (binary indexed tree) under `Tree::FenwickTree` (require
  `tree/fenwicktree`).
* [Segment Tree][] under `Tree::SegmentTree` (require `tree/segmenttree`).
* [B-Tree][] under `Tree::BTree` (require `tree/btree`, key/value pairs).
* [Binary Search Tree][] under `Tree::BinarySearchTreeNode` (require
  `tree/binarysearchtree`).
* [AVL Tree][] under `Tree::AvlTreeNode` (require `tree/avltree`).
* [AA Tree][] under `Tree::AATree` (require `tree/aatree`).
* [Treap][] under `Tree::TreapNode` (require `tree/treap`).
* [Trie][] under `Tree::TrieNode` (require `tree/trie`).
* [Splay Tree][] under `Tree::SplayTreeNode` (require `tree/splaytree`).
* [Red-Black Tree][] under `Tree::RedBlackTreeNode` (require
  `tree/redblacktree`).
* [Interval Tree][] under `Tree::IntervalTreeNode` (require
  `tree/intervaltree`).
* [Order-Statistic Tree][] under `Tree::OrderStatisticTreeNode` (require
  `tree/orderstatistictree`).

Insertion operator (`<<`) support:

* Supported:
  `Tree::TreeNode` and TreeNode-derived node types,
  `Tree::AATree`, `Tree::BTree`.
* Not supported:
  `Tree::FenwickTree`, `Tree::SegmentTree`.
  These classes use explicit indexed updates (`update`, `[]=`) rather than
  append-style insertion semantics.

See [TREE_TYPES](./TREE_TYPES.md) for detailed descriptions, ASCII diagrams,
and use cases for each tree type.

**RubyTree** supports importing from, and exporting to [JSON][], and also
supports the Ruby's standard object [marshaling][].

Note: `Marshal.load` and `JSON.parse(..., create_additions: true)` can execute
code or instantiate objects; do not use them with untrusted input.

This is a [BSD-3 licensed][BSD] open source project, and is hosted at
[github.com/evolve75/RubyTree][rt@github], and is available as a standard gem
from [rubygems.org/gems/rubytree][rt_gem].

The home page for **RubyTree** is at [rubytree.anupamsg.me][rt_site].

## What's New

See [CHANGELOG](./CHANGELOG.md) for the detailed release history and API
change notes.

Cycle creation via `add` is prevented, and explicit cycle validation helpers
are available for untrusted input (see `validate_acyclic!` and `acyclic?`).

## Getting Started

This is a basic usage example of the library to create and manipulate a tree.
See the [API][rt_doc] documentation for more details.

```ruby
# example_basic.rb - This file is part of the RubyTree package.
#
# = example_basic.rb - Basic usage of Tree::TreeNode.
#
# The following example implements this tree structure:
#
#                    +------------+
#                    |    ROOT    |
#                    +-----+------+
#            +-------------+------------+
#            |                          |
#    +-------+-------+          +-------+-------+
#    |  CHILD 1      |          |  CHILD 2      |
#    +-------+-------+          +---------------+
#            |
#            |
#    +-------+-------+
#    | GRANDCHILD 1  |
#    +---------------+
#
#
# Author:: Anupam Sengupta (https://github.com/evolve75)
#
# Copyright (c) 2006-2026 Anupam Sengupta. All rights reserved.
#
# frozen_string_literal: true

# Load JSON for parsing serialized trees.
require 'json'
# Load the core tree library.
require 'tree'

# Create the root node with a name and content.
root_node = Tree::TreeNode.new('ROOT', 'Root Content')
# Print the tree containing only the root.
root_node.print_tree

# Create the first child node.
child1_node = Tree::TreeNode.new('CHILD 1', 'Child1 Content')
# Create the grandchild node.
grandchild1_node = Tree::TreeNode.new('GRANDCHILD 1', 'GrandChild1 Content')
# Add CHILD 1 under ROOT.
root_node << child1_node
# Add GRANDCHILD 1 under CHILD 1.
child1_node << grandchild1_node
# Add CHILD 2 under ROOT.
root_node << Tree::TreeNode.new('CHILD 2', 'Child2 Content')

# Print the updated tree.
root_node.print_tree

# Access CHILD 1 by name.
child1 = root_node['CHILD 1']
# Access GRANDCHILD 1 by name.
grand_child1 = root_node['CHILD 1']['GRANDCHILD 1']

# Collect siblings of CHILD 1.
siblings_of_child1 = child1.siblings
# Display sibling names.
puts "siblings: #{siblings_of_child1.map(&:name).inspect}"

# Collect immediate children of ROOT.
children_of_root = root_node.children
# Display child names.
puts "children: #{children_of_root.map(&:name).inspect}"

# Retrieve the parent of CHILD 1.
parent = child1.parent
# Display the parent name.
puts "parent: #{parent.name}"

# Collect a pre-order traversal of node names.
names = root_node.map(&:name)
# Display traversal results.
puts "preorder: #{names.inspect}"

# Serialize the tree to a hash.
tree_hash = root_node.to_h
# Rebuild a tree from the hash.
from_hash = Tree::TreeNode.from_hash(tree_hash)
# Display the rebuilt root name.
puts "from_hash root: #{from_hash.name}"

# Serialize the tree to JSON.
tree_json = root_node.to_json
# Parse JSON back into a tree instance.
from_json = JSON.parse(tree_json, create_additions: true)
# Display the JSON rebuilt root name.
puts "from_json root: #{from_json.name}"

# Remove CHILD 1 from ROOT.
root_node.remove!(child1)
# Print the tree after removal.
root_node.print_tree
```

This example can also be found at
[examples/example_basic.rb](examples/example_basic.rb).

Additional runnable examples for every supported tree type are available in
the [examples/](examples/) directory.

## Requirements

* [Ruby][] 3.3.x and above. All `2.y.z` releases continue to support Ruby
  2.7 and 3.0; the Ruby 3.3+ requirement begins with the `3.x` release
  line.

Run-time dependencies:

* [JSON][] for converting to/from the JSON format

Development dependencies (not required for installing the gem):

* [Bundler][] for creating the stable build environment
* [Rake][] for building the package
* [YARD][] for the documentation
* Test::Unit for exhaustive edge-case and regression coverage in `test/`
* [RSpec][] for readable common API usage examples in `spec/`
* [RuboCop][] for linting the code

Note: `Tree::TreeNode.new` accepts `{ checks: false }` to disable validation
guards in performance-critical code paths. This is risky and should only be
used when benchmark data clearly justifies the risk.

## Install

To install the [gem][rt_gem], run this command from a terminal/shell:

```bash
gem install rubytree
```

This should install the gem file for **RubyTree**. Note that you might need to
have super-user privileges (root/sudo) to successfully install the gem.

## Documentation

The primary class **RubyTree** is [Tree::TreeNode][TreeNode]. See the class
documentation for an example of using the library.

If the *ri* documentation was generated during install, you can use this
command at the terminal to view the text mode ri documentation:

```bash
ri Tree::TreeNode
```

Documentation for the latest released version is available at:

[rubytree.anupamsg.me/doc][rt_doc]

Note that the documentation is formatted using [YARD][].

Contributor setup and workflows are documented in
[CONTRIBUTING.md](./CONTRIBUTING.md).

## Acknowledgments

A big thanks to the following contributors for helping improve **RubyTree**:

1. Dirk Breuer for contributing the JSON conversion code.
2. Vincenzo Farruggia for contributing the (sub)tree cloning code.
3. [Eric Cline](https://github.com/escline) for the Rails JSON encoding fix.
4. [Darren Oakley](https://github.com/dazoakley) for the tree merge methods.
5. [Youssef Rebahi-Gilbert](https://github.com/ysf) for the code to check
   duplicate node names in the tree (globally unique names).
6. [Paul de Courcel](https://github.com/pdecourcel) for adding the
   `postordered_each` method.
7. [Jen Hamon](https://github.com/jhamon) for adding the `from_hash` method.
8. [Evan Sharp](https://github.com/packetmonkey) for adding the `rename` and
   `rename_child` methods.
9. [Aidan Steele](https://github.com/aidansteele) for performance improvements
   to `is_root?` and `node_depth`.
10. [Marco Ziccadi](https://github.com/MZic) for adding the `path_as_string` and
   `path_as_array` methods.
11. [John Mortlock](https://github.com/jmortlock) for significant modernization
   of the library code and addition of Github `workflows`.
12. [Hermann Mayer](https://github.com/jack12816) for adding support for
   specialized tree nodes (sub-classes of `Tree::TreeNode`).
13. [Jakub Pavlik](https://github.com/igneus) for fixing the creation of
   detached copies of unclonable objects such as `:symbol`, `true|false`, etc.
14. [bghalami-rc](https://github.com/bghalami-rc) for updating the guard clause
   in the `from_hash` method.

## License

**RubyTree** is licensed under the terms of the [BSD][] license. See
[LICENSE.md](./LICENSE.md) for details.

### License Change FAQ

1. What changed?
   RubyTree now standardizes on BSD-3-Clause.

2. Why was this changed?
   BSD-3-Clause adds an explicit non-endorsement clause to prevent
   misrepresentation, so third parties cannot imply maintainer or project
   endorsement of derived products without prior written permission.

3. Does this impact end users of the gem?
   There is no runtime or API impact for gem users. This is a legal/compliance
   clarification only.

4. Does this impact redistributors or downstream packages?
   Redistributors should continue to retain copyright and disclaimer text and
   must not imply endorsement by RubyTree maintainers/contributors.

[BSD]:https://opensource.org/license/bsd-3-clause/
[Binary tree]:https://en.wikipedia.org/wiki/Binary_tree
[Binary Heap]:https://en.wikipedia.org/wiki/Binary_heap
[Binary Max Heap]:https://en.wikipedia.org/wiki/Binary_heap
[Binary Search Tree]:https://en.wikipedia.org/wiki/Binary_search_tree
[Fenwick Tree]:https://en.wikipedia.org/wiki/Fenwick_tree
[Segment Tree]:https://en.wikipedia.org/wiki/Segment_tree
[B-Tree]:https://en.wikipedia.org/wiki/B-tree
[AVL Tree]:https://en.wikipedia.org/wiki/AVL_tree
[AA Tree]:https://en.wikipedia.org/wiki/AA_tree
[Treap]:https://en.wikipedia.org/wiki/Treap
[Trie]:https://en.wikipedia.org/wiki/Trie
[Splay Tree]:https://en.wikipedia.org/wiki/Splay_tree
[Red-Black Tree]:https://en.wikipedia.org/wiki/Red%E2%80%93black_tree
[Interval Tree]:https://en.wikipedia.org/wiki/Interval_tree
[Order-Statistic Tree]:https://en.wikipedia.org/wiki/Order_statistic_tree
[Bundler]:https://bundler.io
[Comparable]:https://ruby-doc.org/core/Comparable.html
[Enumerable]:https://ruby-doc.org/core/Enumerable.html
[JSON]:https://rubygems.org/gems/json
[Rake]:https://rubygems.org/gems/rake
[Ruby]:https://www.ruby-lang.org
[YARD]:https://yardoc.org
[breadth-first]:https://en.wikipedia.org/wiki/Breadth-first_search
[git]:https://git-scm.com
[in-order]:https://en.wikipedia.org/wiki/Tree_traversal#In-order
[marshaling]:https://ruby-doc.org/core/Marshal.html
[post-order]:https://en.wikipedia.org/wiki/Tree_traversal#Post-order
[pre-order]:https://en.wikipedia.org/wiki/Tree_traversal#Pre-order
[rt@github]:https://github.com/evolve75/RubyTree
[rt_doc]:https://rubytree.anupamsg.me/doc/
[rt_gem]:https://rubygems.org/gems/rubytree
[rt_site]:https://rubytree.anupamsg.me
[tree_data_structure]:https://en.wikipedia.org/wiki/Tree_data_structure
[RSpec]:https://rspec.info/
[RuboCop]:https://rubocop.org/
[TreeNode]:rdoc-ref:Tree::TreeNode
[bb]:https://github.com/evolve75/RubyTree/actions/workflows/ruby.yml/badge.svg
[c]:https://github.com/evolve75/RubyTree/actions/workflows/coverage.yml/badge.svg
[cl]:https://github.com/evolve75/RubyTree/actions/workflows/coverage.yml
[gem_version_badge]:https://badge.fury.io/rb/rubytree.png
[gem_version_link]:https://badge.fury.io/rb/rubytree
[gem_downloads_badge]:https://img.shields.io/gem/dt/rubytree
[gem_downloads_link]:https://rubygems.org/gems/rubytree
