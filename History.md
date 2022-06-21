# History of Changes

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

* RubyTree now allows proper sub-classing of [Tree::TreeNode][TreeNode]. Thanks to
  [jack12816][] for this.

* RubyTree now correctly handles creating detached copies of un-clonable objects
  such as `:symbol`, `true|false`, etc. Thanks to [igneus][] for this.

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
  will be _removed_ from its old parent, prior to being added to the new location.

### 0.9.5pre4 / 2014-12-17

* Added performance improvements to [Tree::TreeNode#is_root?][is_root] and
  [Tree::Utils::TreeMetricsHandler#node_depth][mnode_depth]. Thanks to [Aidan Steel][Aidan].

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

* Changed all references to <http://rubyforge.org>.

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

* Refactored the [Tree::TreeNode#each][each] method to prevent stack errors while
  navigating deep trees ([bug-12][]).

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

* Significant refactoring of the documentation. The [Yard][] tags are now
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
  support Rails' `JSON` encoding, by pulling in the changes from [Eric Cline][Eric].

* Partial fix for [bug-5][]. This is to prevent infinite looping if an existing
  node is added again elsewhere in the tree.

* Fixed the issue with using `integers` as node names, and its interaction
  with the `Tree::TreeNode#[]` access method as documented in [bug-6][].

* Clarified the need to have _unique_ node names in the documentation ([bug-7][]).

* Fixed [Tree::TreeNode#siblings][siblings] method to return an _empty_ array
  for the root node as well (it returned `nil` earlier).

### 0.8.2 / 2011-12-15

* Minor bug-fix release to address [bug-1215][] ([Tree::TreeNode#to_s][to_s]
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

* A major bug-fix for [bug-28613][] which impacted the `Binarytree`
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

* Converted the documentation to [Yard][] format.

* Added new methods for converting to/from [JSON][] format. Thanks to Dirk
  [Breuer][] for this [fork](http://github.com/galaxycats/).

* Added a separate [API-CHANGES.md](file:API-CHANGES.md) documentation file.

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

* Fixed [bug-22535][] where the `Tree::TreeNode#depth` method was actually
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

[bug-5]: https://github.com/evolve75/RubyTree/issues/5
[bug-6]: https://github.com/evolve75/RubyTree/issues/6
[bug-7]: https://github.com/evolve75/RubyTree/issues/7
[bug-12]: https://github.com/evolve75/RubyTree/issues/12
[bug-13]: https://github.com/evolve75/RubyTree/issues/13
[bug-23]: https://github.com/evolve75/RubyTree/issues/23
[bug-24]: https://github.com/evolve75/RubyTree/issues/24
[bug-31]: https://github.com/evolve75/RubyTree/issues/31
[bug-32]: https://github.com/evolve75/RubyTree/issues/32
[bug-1215]: http://rubyforge.org/tracker/index.php?func=detail&aid=1215&group_id=1215&atid=4793
[bug-28613]: http://rubyforge.org/tracker/index.php?func=detail&aid=28613&group_id=1215&atid=4793
[bug-22535]: http://rubyforge.org/tracker/index.php?func=detail&aid=22535&group_id=1215&atid=4793

[pr-2]: https://github.com/evolve75/RubyTree/pull/2
[pr-9]: https://github.com/evolve75/RubyTree/pull/9
[pr-35]: https://github.com/evolve75/RubyTree/pull/35

[ArgumentError]: http://www.ruby-doc.org/core-2.0.0/ArgumentError.html
[Bundler]: https://bundler.io
[Comparable]: http://ruby-doc.org/core-1.8.7/Comparable.html
[Enumerator]: http://ruby-doc.org/core-1.8.7/Enumerable.html
[Hoe]: http://www.zenspider.com/projects/hoe.html
[JSON]: http://www.json.org
[RuntimeError]: http://www.ruby-doc.org/core-2.0.0/RuntimeError.html
[Yard]: http://yardoc.org
[ZenTest]: https://github.com/seattlerb/zentest
[dep-warning]: http://rug-b.rubyforge.org/structured_warnings/rdoc/
[gem-testers]: https://test.rubygems.org/
[gemspec]: https://guides.rubygems.org/specification-reference/
[reek]: https://github.com/troessner/reek
[structured-warnings]: http://github.com/schmidt/structured_warnings
[travis-ci]: https://travis-ci.org
[workflow]: https://docs.github.com/en/actions/using-workflows

[Aidan]: https://github.com/aidansteele
[Breuer]: http://github.com/railsbros-dirk
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
[rename]: rdoc-ref:Tree::TreeNode#rename
[rename_child]: rdoc-ref:Tree::TreeNode#rename_child
[siblings]: rdoc-ref:Tree::TreeNode#siblings
[to_s]: rdoc-ref:Tree::TreeNode#to_s
