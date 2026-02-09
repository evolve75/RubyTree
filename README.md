# RubyTree

[![Gem Version][gem_version_badge]][gem_version_link]
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

See [TREE_TYPES](./TREE_TYPES.md) for detailed descriptions, ASCII diagrams,
and use cases for each tree type.

**RubyTree** supports importing from, and exporting to [JSON][], and also
supports the Ruby's standard object [marshaling][].

Note: `Marshal.load` and `JSON.parse(..., create_additions: true)` can execute
code or instantiate objects; do not use them with untrusted input.

This is a [BSD licensed][BSD] open source project, and is hosted at
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
#!/usr/bin/env ruby
#
# example_basic.rb:: Basic usage of the tree library.
#
# Copyright (C) 2013-2022 Anupam Sengupta <https://github.com/evolve75>
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

# ..... Example starts.
require 'tree'                 # Load the library
require 'stringio'

# ..... Create the root node first.
# ..... Note that every node has a name and an optional content payload.
root_node = Tree::TreeNode.new("ROOT", "Root Content")
root_node.print_tree

# ..... Now insert the child nodes.
#       Note that you can "chain" the child insertions to any depth.
root_node << Tree::TreeNode.new("CHILD1", "Child1 Content") <<
  Tree::TreeNode.new("GRANDCHILD1", "GrandChild1 Content")
root_node << Tree::TreeNode.new("CHILD2", "Child2 Content")

# ..... Lets print the representation to stdout.
# ..... This is primarily used for debugging purposes.
root_node.print_tree

# ..... You can capture the output or request a formatted string.
buffer = StringIO.new
root_node.print_tree(io: buffer)
output = root_node.print_tree_to_s

# ..... Lets directly access children and grandchildren of the root.
# ..... These can be "chained" for a given path to any depth.
child1       = root_node["CHILD1"]
grand_child1 = root_node["CHILD1"]["GRANDCHILD1"]

# ..... Now retrieve siblings of the current node as an array.
siblings_of_child1 = child1.siblings

# ..... Retrieve immediate children of the root node as an array.
children_of_root = root_node.children

# ..... Retrieve the parent of a node.
parent = child1.parent

# ..... This is a depth-first and L-to-R pre-ordered traversal.
root_node.each { |node| node.content.reverse }

# ..... Remove a child node from the root node.
root_node.remove!(child1)

# .... Many more methods are available. Check out the documentation!
```

This example can also be found at
[examples/example_basic.rb](examples/example_basic.rb).

## Requirements

* [Ruby][] 3.1.x and above. RubyTree 2.2.0 is the last release that supports
  Ruby 2.7 and 3.0.

Run-time dependencies:

* [JSON][] for converting to/from the JSON format

Development dependencies (not required for installing the gem):

* [Bundler][] for creating the stable build environment
* [Rake][] for building the package
* [YARD][] for the documentation
* [RSpec][] for additional Ruby Spec test files
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

[rubytree.anupamsg.me/rdoc][rt_doc]

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

[BSD]:https://opensource.org/licenses/bsd-license.php
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
[rt_doc]:https://rubytree.anupamsg.me/rdoc
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
