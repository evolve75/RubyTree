# Changelog

This file combines the release history and API change notes for RubyTree.
Use the Release History section for a chronological overview, and the API
Changes section to scan for breaking or behavioral changes.

## Release History

### 3.0.0pre / 2026-02-10

* Standardize project licensing text on BSD-3-Clause and add an explicit
  non-endorsement clause to prevent misrepresentation of maintainer/project
  endorsement in derived products.
* Rationalize RSpec coverage for core tree families so specs emphasize common
  API usage readability, while exhaustive edge-case and regression coverage
  remains in the Test::Unit suite.
* Continue RSpec rationalization across the remaining overlapping tree-family
  specs to keep examples usage-oriented and reduce duplicate scenario matrices.
* Add non-breaking API aliases for consistency:
  `Tree::AATree#lookup`, `Tree::BTree#lookup`,
  `Tree::FenwickTree#query`, `Tree::SegmentTree#query`,
  `Tree::BinaryHeapNode#pop`, `Tree::BinaryMaxHeapNode#pop`,
  and `Tree::TrieNode#search`.
* Add alias-focused regression tests to lock these compatibility contracts.
* Refactor shared binary heap internals into
  `Tree::Utils::HeapSharedMethods` to reduce duplication between min-heap and
  max-heap implementations without changing public behavior.
* Refactor shared array-backed tree API helpers into
  `Tree::Utils::ArrayTreeApiMethods` and use it in `Tree::FenwickTree` and
  `Tree::SegmentTree` without changing public behavior.
* Refactor shared ordered-binary node accessors into
  `Tree::Utils::BinarySearchNodeAccessors` and use it in
  `BinarySearchTreeNode`, `AvlTreeNode`, `RedBlackTreeNode`,
  `SplayTreeNode`, and `TreapNode` without changing public behavior.
* Add Phase 4 stabilization tests covering alias error-parity, empty-structure
  edge behavior, and strict comparable contracts across tree families.
* Make `Tree::TrieNode#<<` use trie word-insert semantics (`insert(word)`)
  instead of generic child-node attachment semantics.
* Add `<<` insertion shorthand to `Tree::AATree` and `Tree::BTree` for
  `[key, value]`, `{ key:, value: }`, and `Entry` inputs.
* Clarify in docs that `Tree::FenwickTree` and `Tree::SegmentTree` do not
  support `<<`, and add tests asserting that unsupported behavior.

### 3.0.0pre / 2026-02-09

* Add runnable example scripts for each supported tree type under `examples/`
  and refresh the core `Tree::TreeNode` example header.
* Expand examples with traversal, update/delete, and JSON round-trip steps
  while aligning example data with the diagrammed structures.
* Link to the full examples directory from the README.
* Note that ambiguous `stringio` spec warnings can be resolved by removing
  extra versions (for example, `gem cleanup stringio`).

### 3.0.0pre / 2026-02-08

* Drop support for Ruby 2.7 and 3.0. Minimum required version is now 3.1.

* Add a per-tree `checks: false` option to skip validation checks when
  performance matters. Some baseline guards (nil children, duplicate child
  names) are always enforced to avoid corrupting the tree. This is still risky
  and can yield unexpected behavior if invalid data is introduced. Only
  disable checks with benchmark data that justifies the risk (see #45).

* Treat `nil` child slots as empty in sibling/child checks to avoid phantom
  nodes in sparse binary trees.

* Skip `nil` child slots when converting to Hash/JSON to avoid errors when
  serializing sparse binary trees.

* Allow `Tree::BinaryTreeNode#add` and `#add_from_hash` to reuse `nil` child
  slots instead of rejecting additional inserts.

* Add explicit cycle validation helpers (`validate_acyclic!`, `acyclic?`) for
  untrusted input.

* Cycle prevention in `add` eliminates the earlier `to_s`/`size` infinite-loop
  risk caused by cyclic graphs.

* Add `cmp` for traversal/relationship-based comparisons (`:each`,
  `:breadth_each`, `:direct_or_sibling`, `:direct_only`) without changing the
  name-based `<=>` semantics.

* Allow `print_tree` to write to a custom IO and add `print_tree_to_s` for
  string output.

* Add markdown lint and link checks via `rake doc:lint` and `rake doc:links`.

* Accept hash-like inputs (`to_hash`) in hash conversion to support Rails
  `HashWithIndifferentAccess` data (see #104).

* Add AVL, AA, Treap, Binary Heap, and Binary Max-Heap implementations with
  ordered insert/search/delete or insert/extract operations.

* Add a Fenwick Tree implementation (`Tree::FenwickTree`) with point updates,
  prefix/range sums, and a TreeNode-like API subset (Enumerable, Comparable,
  array-style accessors, and hash/JSON serialization) aligned with Fenwick
  semantics.

* Add a Segment Tree implementation (`Tree::SegmentTree`) with point updates,
  range sum queries, and a TreeNode-like API subset (Enumerable, Comparable,
  array-style accessors, and hash/JSON serialization) aligned with segment tree
  semantics.

* Add a B-tree implementation (`Tree::BTree`) with ordered insert/search/delete
  operations over key/value pairs.

* Add a Trie implementation (`Tree::TrieNode`) for prefix-based lookup.

* Add a Splay Tree implementation (`Tree::SplayTreeNode`) with ordered
  insert/search/delete operations and splaying on access.

* Add a Red-Black Tree implementation (`Tree::RedBlackTreeNode`) with ordered
  insert/search/delete operations.

* Add an Interval Tree implementation (`Tree::IntervalTreeNode`) with
  overlap and point query helpers.

* Add an Order-Statistic Tree implementation (`Tree::OrderStatisticTreeNode`)
  with rank/select helpers.

* `Tree::BinaryTreeNode#inordered_each` now returns an enumerator for
  `inordered_each` (instead of `each`) when called without a block. This fixes
  the behavior where `node.inordered_each.map` used pre-order traversal.

* `Tree::TreeNode#each_leaf` now returns an enumerator when called without a
  block, matching other traversal methods.

* Reduce intermediate allocations in `Tree::TreeNode#each_level` traversal.

* Ignore nil child slots in `Tree::TreeNode#node_height` so sparse binary trees
  compute heights correctly.

* Add `Tree::TreeNode#children_compact` to return non-nil child nodes while
  retaining `children` behavior for sparse binary trees.

* Remove unused node-depth cache invalidation to avoid misleading state.

* Document Marshal/JSON safety caveats and refresh header years.

* Marshal loading now uses class-level hooks to avoid clobbering the receiver.
  Existing Marshal payloads remain supported.

* Marshal loading hooks are private; use `Marshal.dump` and `Marshal.load`
  instead.

### 2.2.1pre / 2026-02-07

* Simplified development dependency constraints while maintaining Ruby 2.7+
  compatibility. Some upstream updates (e.g., `diff-lcs` 2.x, `erb` 6.x) remain
  on current versions due to Ruby 2.7 support.

### 2.2.0 / 2026-02-06

* Prevent cycles by rejecting attempts to add an ancestor as a child.

* Ensure `remove_all!` detaches children by clearing their parent links.

* Raise on sibling name collisions in `rename_child`.

* Harden binary tree child assignment (`set_child_at`) with proper index errors
  and cleanup of parent/hash references.

* Make traversals resilient to missing children by skipping `nil` nodes in
  `postordered_each` and `breadth_each`.

* Return a level-wise enumerator from `each_level` when no block is given.

* Improve `to_s` formatting to show `<Empty>` for nil content.

### 2.1.1 / 2024-12-19

* 2.1.1 is a minor update that updates all dependencies and updates the guard
  clause for creating a tree from a hash.

### 2.1.0 / 2024-08-12

* Minimum Ruby version has been bumped to 2.7. This is needed to use the
  upstream gems, many of which no longer support 2.6.

* Updated all dependencies to their latest stable versions.

### 2.0.0 / 2022-06-21

* A major release with significant modernization to the code base and removal of
  legacy cruft, thanks to [jmortlock][].

* The long deprecated `Tree::TreeNode#depth` method has finally been
  **removed**. Use [Tree::TreeNode#node_depth][node_depth] instead.

* Support for `CamelCase` methods has been dropped.

* The predicate methods beginning with `is_` or `has_` are now aliases to real
  methods **without** these prefixes. For example, `Tree::TreeNode#is_root?` is
  now aliased to `Tree::TreeNode#root?`. This is to comply with the Ruby
  standard. The original prefixed method names should be considered as
  deprecated and the corresponding non-prefixed method names should be used
  instead. it is possible that the old prefixed method names might be removed in
  the future.

* RubyTree now supports MRI Ruby versions `2.6.x`, `2.7.x`, and `3.0.x`.

* Explicit support for `rbx` Ruby has been removed (_might_ still work, but not
  tested.)

* RubyTree now uses [Github Workflows][workflow] for its CI pipeline.

* RubyTree now allows proper sub-classing of [Tree::TreeNode][TreeNode]. Thanks
  to [jack12816][] for this.

* RubyTree now correctly handles creating detached copies of un-clonable
  objects such as `:symbol`, `true|false`, etc. Thanks to [igneus][] for this.

### 1.0.2 / 2021-12-29

* A minor maintenance version to address a minor but annoying warning for
  circular dependencies.

### 1.0.1 / 2021-12-29

* Updated all dependencies (dev and runtime) to their _latest_ stable
  releases. This is to primarily address potential CVE exposures from upstream
  libraries.

* Updated the supported version of MRI Ruby to `2.7.x`.

* Minor code cleanup using the safe automated corrections using `rubocop`.

* Note that this was never released to <https://rubygems.org>.

### 1.0.0 / 2017-12-21

* Finally! Released version `1.0.0`.

* This is a maintenance release that updates the dependent gem versions and
  addresses a few security vulnerabilities for older upstream gem packages.

* With this release, Rubytree now requires Ruby version `2.2.x` or higher.

### 0.9.7 / 2015-12-31

* Released `0.9.6`. This is a minor bug-fix release.

* This release allows the [Tree::TreeNode#print_tree][print_tree] method to be
  used on non-root nodes. Thanks to [Ojab][Ojab].

* The spaceship operator (`<=>`) now returns `nil` if the object being compared
  to is _itself_ `nil` or not another [Tree::TreeNode][TreeNode].

### 0.9.6 / 2015-05-30

* Released `0.9.6`, which is identical to `0.9.5`, _except_ for an update to the
  gem's release date.

### 0.9.5 / 2015-05-30

* Released `0.9.5`.

### 0.9.5pre7 / 2015-05-30

* Added new methods for getting the path of a node as a `string`. These have
  been added as a new `mixin`
  [Tree::Utils::TreePathHandler][TreePathHandler]. Thanks to [Marco][].

### 0.9.5pre5 / 2015-01-01

* Fixed [bug-32][] and enabled _move_ semantics on the [Tree::TreeNode#add][add]
  method, so that if a child is added, which has an existing parent, then it
  will be _removed_ from its old parent, prior to being added to the new
  location.

### 0.9.5pre4 / 2014-12-17

* Added performance improvements to [Tree::TreeNode#is_root?][is_root] and
  [Tree::Utils::TreeMetricsHandler#node_depth][mnode_depth]. Thanks to
  [Aidan Steel][Aidan].

### 0.9.5pre3 / 2014-12-16

* Minor fix to correct the release date. This release is otherwise identical
  to `0.9.5pre2`.

### 0.9.5pre2 / 2014-12-16

* Added [Tree::TreeNode#rename][rename] and
  [Tree::TreeNode#rename_child][rename_child] methods by merging in code from
  [pr-35][]. Thanks to [Evan Sharp][Evan].

### 0.9.5pre / 2014-11-01

* Fixed [bug-13][] with the patch provided by [Jen Hamon][jhamon].

* Fixed a bug in [Tree::TreeNode#print_tree][print_tree] with the patch provided
  by [Evan Sharp][Evan].

* Fixed [bug-31][], which was causing incorrect behavior in
  [Tree::TreeNode#postordered_each][postordered_each] and
  [Tree::TreeNode#breadth_each][breadth_each] methods when a block was not
  provided.

### 0.9.4 / 2014-07-04

* Changed all references to RubyForge (now offline).
* Legacy RubyForge tracker links were removed since the service is no longer
  available.

### 0.9.3 / 2014-02-01

* Fixed the issue with globally unique node names. See [bug-24][].

### 0.9.2 / 2014-01-03

* Yanked `R0.9.1` as the `History.rdoc` file was not updated.

* Updated the gem description.

* Changed the [travis-ci][] build to include `coverall` support.

### 0.9.1 / 2014-01-03

* Updated the gem description.

* Incorporated code coverage using the `coverall` gem.

### 0.9.0 / 2014-01-02

This is a feature and bug-fix release.

#### The Features

* Rubytree now supports `postordered` traversal via the
  [Tree::TreeNode#postordered_each][postordered_each] method. Thanks to [Paul de
  Courcel][Paul] for this.

* The Binary tree now supports `inorder` traversal via the
  [Tree::BinaryTreeNode#inordered_each][inordered_each] method.

* Ability to merge in another tree at a chosen node, or merge two trees to
  create a third tree. Thanks to [Darren Oakley][Darren] for this [pr-2][].

* RubyTree now mixes in the [Comparable][] module.

#### The Fixes

* (_Partial_) fix for preventing cyclic graphs in the tree.

* Refactored the [Tree::TreeNode#each][each] method to prevent stack errors
  while navigating deep trees ([bug-12][]).

* Check to ensure that the added node's name is unique to the destination tree
  ([pr-9][]). Thanks to [Youssef Rebahi-Gilbert][Youssef] for the idea and the
  initial code.

* Fix for [bug-23][], where the tree traversal on a binary tree would fail if
  the _left_ child was `nil`.

* The following traversal methods now correctly return an
  [Enumerator][] as the return value when no block is given, and
  return the _receiver node_ if a block was provided. This is consistent with
  how the standard Ruby collections work.

* [Tree::TreeNode#each][each],
* [Tree::TreeNode#preordered_each][preordered_each],
* [Tree::TreeNode#postordered_each][postordered_each] and
* [Tree::TreeNode#breadth_each][breadth_each].

#### Other Changes

* Structural changes in the code to refactor out the non-core functions into
  modules (mostly by extracting out non-core code as `mixins`).

* Significant refactoring of the documentation. The [YARD][] tags are now
  extensively used.

* Basic support built-in for including example code in the gem. This will be
  fully expanded in the next release.

* Various changes to the [Bundler][], [travis-ci][] and other `Rakefile`
  changes.

### 0.8.3 / 2012-08-21

This is a primarily a bug-fix release, with some packaging changes.

* Have removed the dependency on [Hoe][]. The build is now based on vanilla
  [gemspec][].

* Included support for [gem-testers][].

* Included support for [Bundler][].

* Implemented the [Tree::Utils::JSONConverter#as_json][as_json] method to
  support Rails' `JSON` encoding, by pulling in the changes from
  [Eric Cline][Eric].

* Partial fix for bug-5 (issue link unavailable). This is to prevent infinite looping if an existing
  node is added again elsewhere in the tree.

* Fixed the issue with using `integers` as node names, and its interaction
  with the `Tree::TreeNode#[]` access method as documented in [bug-6][].

* Clarified the need to have _unique_ node names in the documentation
  ([bug-7][]).

* Fixed [Tree::TreeNode#siblings][siblings] method to return an _empty_ array
  for the root node as well (it returned `nil` earlier).

### 0.8.2 / 2011-12-15

* Minor bug-fix release to address bug 1215 (RubyForge tracker, offline)
  ([Tree::TreeNode#to_s][to_s]
  breaks if `@content` or `@parent.name` is not a string).

### 0.8.1 / 2010-10-02

* This is the public release of `R0.8.0`, with additional bug-fixes. Note that
  `R0.8.0` will **not be** released separately as a publicly available
  Rubygem. All changes as listed for `R0.8.0` are available in this release.

* The main change in `R0.8.0`/`R0.8.1` is conversion of all `CamelCase` method
  names to `snake_case`. The old `CamelCase` method names will _still_ work (to
  ensure backwards compatibility), but will also display a warning.

* The [Tree::TreeNode#add][add] method now accepts an _optional_ child insertion
  point.

* The sub-tree from the current node can now be cloned in its _entirety_ using
  the [Tree::TreeNode#detached_subtree_copy][detached_subtree_copy] method.

* A major bug-fix for bug 28613 (RubyForge tracker, offline) which impacted
  the `Binarytree`
  implementation.

* Minor code re-factoring driven by the code-smell checks using
  [reek][].

* Inclusion of the `reek` code-smell detection tool in the `Rakefile`.

### 0.8.0 / 2010-05-04

* Updated the [Tree::TreeNode#add][add] method to allow the optional
  specification of an insertion position in the child array.

* Added a new method
  [Tree::TreeNode#detached_subtree_copy][detached_subtree_copy] to allow cloning
  the entire tree (this method is also aliased as `dup`).

* Converted all `CamelCase` method names to the canonical `ruby_method_names`
  (underscore separated). The `CamelCase` methods _can still_ be invoked, but
  will throw a [Deprecated Warning][dep-warning]. The support for old
  `CamelCase` methods **will** go away some time in the future, so the user is
  advised to convert all current method invocations to the new names.

### 0.7.0 / 2010-05-03

* Added new methods to report the degree-statistics of a node.

* Added a convenience method alias [Tree::TreeNode#level][level] to `nodeDepth`.

* Converted the exceptions thrown on invalid arguments to [ArgumentError][]
  instead of [RuntimeError][].

* Converted the documentation to [YARD][] format.

* Added new methods for converting to/from [JSON][] format. Thanks to Dirk
  Breuer for the galaxycats fork.

* Added a separate API changes section in CHANGELOG.md.

* Added fixes for root related edge conditions to the:

* [Tree::TreeNode#is_only_child?][is_only_child],
* [Tree::TreeNode#next_sibling][next_sibling],
* [Tree::TreeNode#previous_sibling][previous_sibling] and
* [Tree::TreeNode#remove!][remove] methods.

* Removed the `ChangeLog` file as this can now be generated from the git logs.

* Other minor code cleanup.

### 0.6.2 / 2010-01-30

* Updated the documentation.

### 0.6.1 / 2010-01-04

* Changed the hard-dependency on the [structured_warnings][] gem to a
  _soft-dependency_ - which lets `RubyTree` still work if this gem is not
  available. The rationale for this is that we _should not_ require the user to
  install a separate library just for _one_ edge-case function (in this case, to
  indicate a deprecated method). However, if the library *is* available on the
  user's system, then it **will** get used.

### 0.6.0 / 2010-01-03

* Fixed bug 22535 (RubyForge tracker, offline) where the
  `Tree::TreeNode#depth` method was actually
  returning `height+1` (**not** the `depth`).

* Marked the `Tree::TreeNode#depth` method as **deprecated** (and introduced the
  run-time dependency on the [structured-warnings][] gem).

### 0.5.3 / 2009-12-31

* Cleanup of the build system to exclusively use [Hoe][].
* Modifications and reformatting to the documentation.
* No user visible changes.

### 0.5.2 / 2007-12-21

* Added more test cases and enabled [ZenTest][] compatibility for the test case
  names.

### 0.5.1 / 2007-12-20

* Minor code refactoring.

### 0.5.0 / 2007-12-18

* Fixed the marshalling code to correctly handle non-string content.

### 0.4.3 / 2007-10-09

* Changes to the build mechanism (now uses [Hoe]).

### 0.4.2 / 2007-10-01

* Minor code refactoring. Changes in the `Rakefile`.

[bug-6]: https://github.com/evolve75/RubyTree/issues/6
[bug-7]: https://github.com/evolve75/RubyTree/issues/7
[bug-12]: https://github.com/evolve75/RubyTree/issues/12
[bug-13]: https://github.com/evolve75/RubyTree/issues/13
[bug-23]: https://github.com/evolve75/RubyTree/issues/23
[bug-24]: https://github.com/evolve75/RubyTree/issues/24
[bug-31]: https://github.com/evolve75/RubyTree/issues/31
[bug-32]: https://github.com/evolve75/RubyTree/issues/32
[pr-2]: https://github.com/evolve75/RubyTree/pull/2
[pr-9]: https://github.com/evolve75/RubyTree/pull/9
[pr-35]: https://github.com/evolve75/RubyTree/pull/35

[ArgumentError]: https://ruby-doc.org/core/ArgumentError.html
[Bundler]: https://bundler.io
[Comparable]: https://ruby-doc.org/core/Comparable.html
[Enumerator]: https://ruby-doc.org/core/Enumerable.html
[Hoe]: https://www.zenspider.com/projects/hoe.html
[JSON]: https://www.json.org/
[RuntimeError]: https://ruby-doc.org/core/RuntimeError.html
[YARD]: https://yardoc.org
[ZenTest]: https://github.com/seattlerb/zentest
[dep-warning]: https://github.com/schmidt/structured_warnings
[gem-testers]: https://github.com/rubygems/gem-testers
[gemspec]: https://guides.rubygems.org/specification-reference/
[reek]: https://github.com/troessner/reek
[structured-warnings]: https://github.com/schmidt/structured_warnings
[travis-ci]: https://travis-ci.org
[workflow]: https://docs.github.com/en/actions/using-workflows

[Aidan]: https://github.com/aidansteele
[Darren]: https://github.com/dazoakley
[Eric]: https://github.com/escline
[Evan]: https://github.com/packetmonkey
[Marco]: https://github.com/MZic
[Ojab]: https://github.com/ojab
[Paul]: https://github.com/pdecourcel
[Youssef]: https://github.com/ysf
[igneus]: https://github.com/igneus
[jack12816]: https://github.com/jack12816
[jhamon]: https://www.github.com/jhamon
[jmortlock]: https://github.com/jmortlock

[TreeNode]: rdoc-ref:Tree::TreeNode
[TreePathHandler]: Tree::Utils::TreePathHandler
[add]: rdoc-ref:Tree::TreeNode#add
[as_json]: rdoc-ref:Tree::Utils::JSONConverter#as_json
[breadth_each]: rdoc-ref:Tree::TreeNode#breadth_each
[detached_subtree_copy]: rdoc-ref:Tree::TreeNode#detached_subtree_copy
[each]: rdoc-ref:Tree::TreeNode#each
[inordered_each]: rdoc-ref:Tree::BinaryTreeNode#inordered_each
[is_only_child]: rdoc-ref:Tree::TreeNode#is_only_child?
[is_root]: rdoc-ref:Tree::TreeNode#is_root?
[level]: rdoc-ref:Tree::TreeNode#level
[mnode_depth]: rdoc-ref:Tree::Utils::TreeMetricsHandler#node_depth
[next_sibling]: rdoc-ref:Tree::TreeNode#next_sibling
[node_depth]: rdoc-ref:Tree::TreeNode#node_depth
[postordered_each]: rdoc-ref:Tree::TreeNode#postordered_each
[previous_sibling]: rdoc-ref:Tree::TreeNode#previous_sibling
[print_tree]: rdoc-ref:Tree::TreeNode#print_tree
[remove]: rdoc-ref:Tree::TreeNode#remove!
[avl_tree_node]: rdoc-ref:Tree::AvlTreeNode
[treap_node]: rdoc-ref:Tree::TreapNode
[trie_node]: rdoc-ref:Tree::TrieNode
[splay_tree_node]: rdoc-ref:Tree::SplayTreeNode
[red_black_tree_node]: rdoc-ref:Tree::RedBlackTreeNode
[each_leaf]: rdoc-ref:Tree::TreeNode#each_leaf
[rename]: rdoc-ref:Tree::TreeNode#rename
[rename_child]: rdoc-ref:Tree::TreeNode#rename_child
[siblings]: rdoc-ref:Tree::TreeNode#siblings
[to_s]: rdoc-ref:Tree::TreeNode#to_s

## API Changes

This lists the various API changes that have been made to the `RubyTree`
package.

_Note_: API changes are expected to reduce significantly after the `1.x`
release. In most cases, an alternative will be provided to ensure relatively
smooth transition to the new APIs.

## Release 3.0.0 Changes

* Minimum Ruby version is now 3.1 (support for 2.7 and 3.0 has been dropped).

* [Tree::TreeNode#children?][children] and [Tree::TreeNode#siblings][siblings]
  now treat `nil` child slots as empty, preventing binary trees with missing
  children from reporting or yielding phantom siblings.

* Added [Tree::TreeNode#validate_acyclic!][validate_acyclic] and
  [Tree::TreeNode#acyclic?][acyclic] to detect cycles in untrusted trees.

* Added [Tree::TreeNode#cmp][cmp] to compare nodes using traversal or
  relationship policies without changing the name-based `<=>` behavior.

* [Tree::TreeNode#print_tree][print_tree] now accepts an `io:` keyword to
  redirect output (defaults to `$stdout`), and
  [Tree::TreeNode#print_tree_to_s][print_tree_to_s] returns the formatted
  output as a string.

* [Tree::BinaryTreeNode#inordered_each][inordered_each] now returns an
  enumerator for `inordered_each` (instead of `each`) when called without a
  block. This fixes the behavior where `node.inordered_each.map` used pre-order
  traversal.

* [Tree::TreeNode#each_leaf][each_leaf] now returns an enumerator when called
  without a block, matching the other traversal helpers.

* Marshal loading now uses class-level hooks, returning a new tree instead of
  mutating the receiver.

* Marshal loading hooks are now private; use `Marshal.dump` and `Marshal.load`
  instead.

* Hash conversion now accepts hash-like inputs (objects responding to
  `to_hash`) to improve interoperability with frameworks such as Rails
  (see #104).

* Added [Tree::AvlTreeNode][avl_tree_node] for a balanced binary search tree
  using AVL rotations.

* Added [Tree::TreapNode][treap_node] for a randomized balanced search tree
  using heap-ordered priorities.

* Added [Tree::TrieNode][trie_node] for prefix-based string lookup.

* Added [Tree::SplayTreeNode][splay_tree_node] for self-adjusting access
  patterns via splaying rotations.

* Added [Tree::RedBlackTreeNode][red_black_tree_node] for a balanced binary
  search tree with red-black invariants.

* Added per-tree validation toggles via `checks: false` on `Tree::TreeNode.new`
  to allow disabling guard checks in performance-critical code paths. Some
  baseline guards (nil child checks, duplicate child name checks) are always
  enforced to avoid corrupting the tree. Disabling checks is still potentially
  dangerous and can lead to unexpected behavior if invalid data enters the tree.
  Only disable checks with clear performance benchmark data supporting the risk
  (see #45).

## Release 2.2.0 Changes

* [Tree::TreeNode#add][add] now raises `ArgumentError` when attempting to add
  an ancestor node as a child, preventing cycles.

* [Tree::TreeNode#remove_all!][remove_all] now detaches children by clearing
  their parent links.

* [Tree::TreeNode#rename_child][rename_child] now raises `ArgumentError` if the
  new name collides with an existing sibling.

* [Tree::BinaryTreeNode#set_child_at][set_child_at] now raises `ArgumentError`
  for invalid indices and cleans up parent/hash references when replacing or
  clearing a child.

* [Tree::TreeNode#postordered_each][postordered_each] and
  [Tree::TreeNode#breadth_each][breadth_each] now skip `nil` children to
  support binary trees with missing children.

* [Tree::TreeNode#each_level][each_level] now returns a level-wise enumerator
  when called without a block.

## Release 2.1.0 Changes

* Minimum Ruby version has been bumped to 2.7 and above

* Updated all upstream dependencies to their latest stable versions

## Release 2.0.0 Changes

* The _minimum_ required Ruby version is now `2.6` (or higher).

* The long-broken `Tree::TreeNode#depth` method has _finally_ been removed. Use
  [Tree::TreeNode#node_depth][node_depth] instead.

* Support for `CamelCase` methods has been removed. This was a legacy shim
  that has hopefully outlived its usefulness.

* Use of integers as node-names now no longer requires the optional
  `num_as_name` method argument.

* The predicate methods beginning with `is_` or `has_` are now aliases to the
  real methods **without** these prefixes. For example,
  `Tree::TreeNode#is_root?` is now aliased to `Tree::TreeNode#root?`. This is to
  comply with the Ruby standard. These original prefixed method names should be
  considered as deprecated and the corresponding non-prefixed method names
  should be used instead. it is possible that the old prefixed method names
  might be removed in the future.

* [structured_warnings][] has been **removed** from the code-base and is no
  longer a dependency. This was a long-standing point of friction for many
  users.

## Release 0.9.5 Changes

* The [Tree::TreeNode#add][add] method now provides **move** semantics, if a
  child node on an existing tree is added to another tree, or another location
  on the same tree. In this situation, the child node is removed from its old
  position and added to the new parent node. After the add operation is
  complete, the child no longer exists on the old tree/location.

## Release 0.9.3 Changes

* Validation for unique node names has changed in the [Tree::TreeNode#add][add]
  method. `RubyTree` no longer enforces globally unique names. The node-names
  need to be unique _only between_ the sibling nodes.

## Release 0.9.0 Changes

* New post-ordered traversal via the
  [Tree::TreeNode#postordered_each][postordered_each] method.

* The Binary Tree implementation now supports in-order traversal via the
  [Tree::BinaryTreeNode#inordered_each][inordered_each] method.

* `RubyTree` now mixes in the
  [Comparable][] module.

* The traversal methods ([Tree::TreeNode#each][each],
  [Tree::TreeNode#preordered_each][preordered_each],
  [Tree::TreeNode#postordered_each][postordered_each] and
  [Tree::TreeNode#breadth_each][breadth_each] now correctly return an
  [Enumerator][] as the return value when no block is given, and return the
  receiver node if a block was provided. This is consistent with how the
  standard Ruby collections work.

## Release 0.8.3 Changes

* [Tree::TreeNode#siblings][siblings] will now return an empty array for the
  root node.

## Release 0.8.0 Changes

* Added the ability to specify an optional insertion position in the
  [Tree::TreeNode#add][add] method. Idea and original code contributed by Dirk.

* Added a new method
  [Tree::TreeNode#detached_subtree_copy][detached_subtree_copy] to allow cloning
  the entire tree. This method is also aliased to
  [Tree::TreeNode#dup][dup]. Idea and original code contributed by Vincenzo
  Farruggia.

* Converted all _CamelCase_ method names to the canonical ruby_method_names
  (underscore separated). The CamelCase methods can still be invoked, but
  will throw a deprecated warning.

## Release 0.7.0 Changes

* Converted all exceptions thrown on invalid method arguments to from
  `RuntimeError` to `ArgumentError`. This impacts the following methods:

* [Tree::TreeNode#initialize][initialize]
* [Tree::TreeNode#add][add]
* [Tree::TreeNode#[]][access]
* [Tree::BinaryTreeNode#add][btree_add]
* Added [Tree::TreeNode#level][level] as an alias for
  [Tree::TreeNode#node_depth][node_depth]

* Added new methods [Tree::TreeNode#in_degree][in_degree] and
  [Tree::TreeNode#out_degree][out_degree] to report the node's degree stats.

* [Tree::TreeNode#is_only_child?][is_only_child] now returns `true` for a root
  node.

* [Tree::TreeNode#next_sibling][next_sibling] and
  [Tree::TreeNode#previous_sibling][previous_sibling] now return `nil` for a
  root node.

* [Tree::TreeNode#add][add] and [Tree::TreeNode#<<][append] now throw an
  `ArgumentError` exception if a `nil` node is passed as an argument.

* Added new methods [Tree::TreeNode#to_json][to_json] and
  [Tree::TreeNode#json_create][json_create] to convert to/from the JSON format.
  Thanks to Dirk Breuer for this change.

## Release 0.6.1 Changes

* Deprecated the [Tree::Utils::TreeMetricsHandler#depth][depth] method as it was
  returning an incorrect depth value. Have introduced a new replacement method
  [Tree::Utils::TreeMetricsHandler#node_depth][node_depth] which returns the
  correct result.

[structured_warnings]:https://github.com/schmidt/structured_warnings

[access]: rdoc-ref:Tree::TreeNode#[]
[add]: rdoc-ref:Tree::TreeNode#add
[acyclic]: rdoc-ref:Tree::TreeNode#acyclic?
[append]: rdoc-ref:Tree::TreeNode#<<
[breadth_each]: rdoc-ref:Tree::TreeNode#breadth_each
[btree_add]: rdoc-ref:Tree::BinaryTreeNode#add
[children]: rdoc-ref:Tree::TreeNode#children?
[cmp]: rdoc-ref:Tree::TreeNode#cmp
[depth]: rdoc-ref:Tree::Utils::TreeMetricsHandler#depth
[detached_subtree_copy]: rdoc-ref:Tree::TreeNode#detached_subtree_copy
[dup]: rdoc-ref:Tree::TreeNode#dup
[each]: rdoc-ref:Tree::TreeNode#each
[each_level]: rdoc-ref:Tree::TreeNode#each_level
[in_degree]: rdoc-ref:Tree::Utils::TreeMetricsHandler#in_degree
[initialize]: rdoc-ref:Tree::TreeNode#initialize
[inordered_each]: rdoc-ref:Tree::BinaryTreeNode#inordered_each
[is_only_child]: rdoc-ref:Tree::TreeNode#is_only_child?
[json_create]: rdoc-ref:Tree::Utils::JSONConverter::ClassMethods#json_create
[level]: rdoc-ref:Tree::Utils::TreeMetricsHandler#level
[next_sibling]: rdoc-ref:Tree::TreeNode#next_sibling
[node_depth]: rdoc-ref:Tree::Utils::TreeMetricsHandler#node_depth
[out_degree]: rdoc-ref:Tree::Utils::TreeMetricsHandler#out_degree
[postordered_each]: rdoc-ref:Tree::TreeNode#postordered_each
[preordered_each]: rdoc-ref:Tree::TreeNode#preordered_each
[print_tree]: rdoc-ref:Tree::TreeNode#print_tree
[print_tree_to_s]: rdoc-ref:Tree::TreeNode#print_tree_to_s
[previous_sibling]: rdoc-ref:Tree::TreeNode#previous_sibling
[remove_all]: rdoc-ref:Tree::TreeNode#remove_all!
[rename_child]: rdoc-ref:Tree::TreeNode#rename_child
[set_child_at]: rdoc-ref:Tree::BinaryTreeNode#set_child_at
[siblings]: rdoc-ref:Tree::TreeNode#siblings
[to_json]: rdoc-ref:Tree::Utils::JSONConverter#to_json
[validate_acyclic]: rdoc-ref:Tree::TreeNode#validate_acyclic!
