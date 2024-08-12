# API Changes in RubyTree

This lists the various API changes that have been made to the `RubyTree`
package.

_Note_: API changes are expected to reduce significantly after the `1.x`
release. In most cases, an alternative will be provided to ensure relatively
smooth transition to the new APIs.

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
  [Comparable](http://ruby-doc.org/core-1.8.7/Comparable.html) module.

* The traversal methods ([Tree::TreeNode#each][each],
  [Tree::TreeNode#preordered_each][preordered_each],
  [Tree::TreeNode#postordered_each][postordered_each] and
  [Tree::TreeNode#breadth_each][breadth_each] now correctly return an
  [Enumerator](rdoc-ref:http://ruby-doc.org/core-1.8.7/Enumerable.html) as the
  return value when no block is given, and return the receiver node if a block
  was provided. This is consistent with how the standard Ruby collections work.

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

* Added new methods
    [Tree::TreeNode#to_json][to_json] and
    [Tree::TreeNode#json_create][json_create]
    to convert to/from the JSON format. Thanks to
    [Dirk](http://github.com/railsbros-dirk) for this change.

## Release 0.6.1 Changes

* Deprecated the [Tree::Utils::TreeMetricsHandler#depth][depth] method as it was
  returning an incorrect depth value. Have introduced a new replacement method
  [Tree::Utils::TreeMetricsHandler#node_depth][node_depth] which returns the
  correct result.


[structured_warnings]: https://github.com/schmidt/structured_warnings

[access]: rdoc-ref:Tree::TreeNode#[]
[add]: rdoc-ref:Tree::TreeNode#add
[append]: rdoc-ref:Tree::TreeNode#<<
[breadth_each]: rdoc-ref:Tree::TreeNode#breadth_each
[btree_add]: rdoc-ref:Tree::BinaryTreeNode#add
[depth]: rdoc-ref:Tree::Utils::TreeMetricsHandler#depth
[detached_subtree_copy]: rdoc-ref:Tree::TreeNode#detached_subtree_copy
[dup]: rdoc-ref:Tree::TreeNode#dup
[each]: rdoc-ref:Tree::TreeNode#each
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
[previous_sibling]: rdoc-ref:Tree::TreeNode#previous_sibling
[siblings]: rdoc-ref:Tree::TreeNode#siblings
[to_json]: rdoc-ref:Tree::Utils::JSONConverter#to_json
