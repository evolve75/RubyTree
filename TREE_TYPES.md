# Tree Types Reference

<!-- markdownlint-disable-file MD013 -->

This document summarizes the tree types available in RubyTree, with
descriptions, sketches, typical use cases, and references. It is intended to
help you choose a tree type that fits your data shape and performance needs.

## Table of Contents

- [Quick Selection Guide](#quick-selection-guide)
- [Comparison Snapshot](#comparison-snapshot)
- [Complexity Notes (Typical)](#complexity-notes-typical)
- [Common Pitfalls](#common-pitfalls)
- [Serialization and Interchange](#serialization-and-interchange)
- [Usage Notes](#usage-notes)
- [Quick Examples](#quick-examples)
- [Generic Tree (Tree::TreeNode)](#generic-tree-treetreenode)
- [Binary Tree (Tree::BinaryTreeNode)](#binary-tree-treebinarytreenode)
- [Binary Search Tree (Tree::BinarySearchTreeNode)](#binary-search-tree-treebinarysearchtreenode)
- [AVL Tree (Tree::AvlTreeNode)](#avl-tree-treeavltreenode)
- [Red-Black Tree (Tree::RedBlackTreeNode)](#red-black-tree-treeredblacktreenode)
- [Treap (Tree::TreapNode)](#treap-treetreapnode)
- [Splay Tree (Tree::SplayTreeNode)](#splay-tree-treesplaytreenode)
- [Binary Heap (Tree::BinaryHeapNode)](#binary-heap-treebinaryheapnode)
- [Binary Max-Heap (Tree::BinaryMaxHeapNode)](#binary-max-heap-treebinarymaxheapnode)
- [Fenwick Tree (Tree::FenwickTree)](#fenwick-tree-treefenwicktree)
- [Segment Tree (Tree::SegmentTree)](#segment-tree-treesegmenttree)
- [B-Tree (Tree::BTree)](#b-tree-treebtree)
- [Trie (Tree::TrieNode)](#trie-treetrienode)

## Quick Selection Guide

If you want:

- A general hierarchy without ordering, use `Tree::TreeNode`.
- Sorted data with predictable performance, use `Tree::AvlTreeNode` or
  `Tree::RedBlackTreeNode`.
- Sorted data with locality of access, use `Tree::SplayTreeNode`.
- Simple sorted data without strict balance, use `Tree::BinarySearchTreeNode`.
- Priority queues, use `Tree::BinaryHeapNode` (min-heap) or
  `Tree::BinaryMaxHeapNode` (max-heap).
- Fast prefix/range sums on arrays, use `Tree::FenwickTree`.
- General range queries with point updates, use `Tree::SegmentTree`.
- Large ordered datasets with fewer node traversals, use `Tree::BTree`.
- Prefix-based string lookup, use `Tree::TrieNode`.

## Comparison Snapshot

Abbreviations used in the table map to the Ruby types in the sections below.

| Type       | Ord    | Bal               | Ops          | Mem      | Use              |
|------------|--------|-------------------|--------------|----------|------------------|
| TreeNode   | No     | N/A               | add/visit    | Low      | Hierarchy        |
| BinaryTree | No     | N/A               | add/visit    | Low      | Binary shape     |
| BST        | Yes    | Worst O(n)        | s/i/d        | Low      | Simple order     |
| AVL        | Yes    | Strong O(log n)   | s/i/d        | Med      | Predictable      |
| RBT        | Yes    | Strong O(log n)   | s/i/d        | Med      | Frequent updates |
| Treap      | Yes    | Expected O(log n) | s/i/d        | Med      | Simple balance   |
| Splay      | Yes    | Amort O(log n)    | s/i/d        | Med      | Locality         |
| Min-Heap   | No     | Heap              | peek/ins/ext | Low      | Priority queue   |
| Max-Heap   | No     | Heap              | peek/ins/ext | Low      | Priority queue   |
| Fenwick    | N/A    | Prefix            | update/sum   | Low      | Prefix sums      |
| Segment    | N/A    | Range             | update/query | Med      | Range queries    |
| B-Tree     | Yes    | Strong O(log n)   | s/i/d        | Med/High | Large datasets   |
| Trie       | Prefix | Key len           | insert/find  | High     | Prefix search    |

## Complexity Notes (Typical)

These are typical (not worst-case) costs. Specific workloads and balancing
properties can change the constants.

Operation categories:

- Search/Insert/Delete for ordered trees.
- Update/Query for numeric range structures.

Typical costs:

- Binary search tree: O(log n) average, O(n) worst-case.
- AVL / Red-black: O(log n) worst-case for search/insert/delete.
- Treap: O(log n) expected for search/insert/delete.
- Splay: O(log n) amortized.
- Binary heap: O(log n) insert/extract, O(1) peek.
- Fenwick: O(log n) point update, O(log n) prefix/range sum.
- Segment tree: O(log n) point update, O(log n) range query.
- B-tree: O(log n) for search/insert/delete (lower height, higher node cost).
- Trie: O(k) where k is key length.

## Common Pitfalls

- Binary search trees can degrade to O(n) if inserts are already ordered.
- Heaps are not sorted; in-order traversal does not yield ordered values.
- Splay trees are amortized; a single operation can still be expensive.
- Fenwick trees support prefix/range sums but do not support arbitrary range
  updates without extensions.
- Segment trees are more flexible than Fenwick trees but use more memory.
- Tries can consume significant memory for large alphabets.

## Serialization and Interchange

Most tree types provide `to_h` / `from_hash` and JSON helpers (`as_json`,
`to_json`, `json_create`). TreeNode-derived types follow TreeNode serialization
conventions, while array-backed trees (Fenwick, Segment) and multi-entry trees
(B-Tree) use type-appropriate layouts.

## Usage Notes

- TreeNode-derived types: `Tree::TreeNode`, `Tree::BinaryTreeNode`,
  `Tree::BinarySearchTreeNode`, `Tree::AvlTreeNode`, `Tree::RedBlackTreeNode`,
  `Tree::TreapNode`, `Tree::SplayTreeNode`, `Tree::BinaryHeapNode`,
  `Tree::BinaryMaxHeapNode`, `Tree::TrieNode`.
- Non-TreeNode types: `Tree::FenwickTree`, `Tree::SegmentTree`, `Tree::BTree`.

These non-TreeNode types provide a TreeNode-like subset where it fits their
semantics (Enumerable iteration, Comparable, and serialization).

## Quick Examples

```ruby
require 'tree'

# Generic tree
root = Tree::TreeNode.new('root')
root << Tree::TreeNode.new('child')

# Binary tree (explicit left/right)
require 'tree/binarytree'
binary = Tree::BinaryTreeNode.new('root')
binary.left = Tree::BinaryTreeNode.new('left')

# Binary search tree
require 'tree/binarysearchtree'
bst = Tree::BinarySearchTreeNode.new(8)
bst.insert(3)

# Ordered tree (AVL)
require 'tree/avltree'
avl = Tree::AvlTreeNode.new(10)
avl.insert(5)

# Red-black tree
require 'tree/redblacktree'
rbt = Tree::RedBlackTreeNode.new(10)
rbt.insert(5)

# Treap
require 'tree/treap'
treap = Tree::TreapNode.new(10)
treap.insert(5)

# Splay tree
require 'tree/splaytree'
splay = Tree::SplayTreeNode.new(10)
splay.insert(5)

# Priority queue (min-heap)
require 'tree/binaryheap'
heap = Tree::BinaryHeapNode.new(3)
heap.insert(1)

# Priority queue (max-heap)
require 'tree/binarymaxheap'
max_heap = Tree::BinaryMaxHeapNode.new(3)
max_heap.insert(9)

# Prefix sums (Fenwick)
require 'tree/fenwicktree'
fenwick = Tree::FenwickTree.new(3, [1, 2, 3])
fenwick.sum(2)

# Range sums (Segment tree)
require 'tree/segmenttree'
segment = Tree::SegmentTree.new(3, [1, 2, 3])
segment.range_sum(0, 2)

# B-Tree (key/value)
require 'tree/btree'
btree = Tree::BTree.new(2)
btree.insert('a', 1)

# Trie
require 'tree/trie'
trie = Tree::TrieNode.new('')
trie.insert('cat')

```

## Generic Tree (Tree::TreeNode)

**Ruby type:** `Tree::TreeNode` (require `tree`)

**Description:** A general-purpose, node-centric tree where each node has a
name, optional content, and an arbitrary number of children. This is the most
flexible structure in the library and provides rich navigation, traversal,
comparison, and serialization helpers.

**Motivation:** Use this when you need a simple, expressive hierarchy and do
not need strict ordering or balancing constraints.

**When not to use:** Avoid if you need ordered lookups or strict performance
guarantees on search/insert/delete.

**Structure:**

```text
        +-------+
        | ROOT  |
        +---+---+
            |
    +-------+-------+
    |               |
 +--+---+       +---+--+
 |CHILD|       |CHILD2|
 +-----+       +------+

```

**Uses:**
- Representing hierarchical data (menus, org charts, file trees)
- General-purpose in-memory trees
- Custom domain trees with arbitrary branching

**API notes:** Full TreeNode API (navigation, traversal, comparison,
serialization).

**TreeNode differences:** This is the baseline API.

**References:**
- [Tree data structure](https://en.wikipedia.org/wiki/Tree_data_structure)
- [N-ary tree](https://en.wikipedia.org/wiki/K-ary_tree)

## Binary Tree (Tree::BinaryTreeNode)

**Ruby type:** `Tree::BinaryTreeNode` (require `tree/binarytree`)

**Description:** A TreeNode-derived structure where each node has at most two
children (left and right). It is a foundational shape for ordered or balanced
trees, and is also useful on its own for binary decision structures.

**Motivation:** Choose this when you want binary branching without enforcing
ordering constraints.

**When not to use:** Avoid if you need ordered data or balanced search.

**Structure:**

```text
    +---+
    | A |
    +-+-+
      |
   +--+--+
   |     |
 +--+   +--+
 |B |   |C |
 +--+   +--+

```

**Uses:**
- Foundation for ordered/balanced tree variants
- Binary expression trees
- Binary decision trees

**API notes:** Full TreeNode API with left/right child semantics.

**TreeNode differences:** Inherits TreeNode but restricts child count and uses
left/right child semantics.

**References:**
- [Binary tree](https://en.wikipedia.org/wiki/Binary_tree)

## Binary Search Tree (Tree::BinarySearchTreeNode)

**Ruby type:** `Tree::BinarySearchTreeNode` (require `tree/binarysearchtree`)

**Description:** A binary tree where keys are ordered so that left subtree keys
are less than the node key and right subtree keys are greater. In-order
traversal yields keys in sorted order.

**Motivation:** Use this for ordered data when you want a simple structure and
can tolerate worst-case imbalance.

**When not to use:** Avoid if input order is likely to be sorted or adversarial.

**Structure:**

```text
      8
     / \
    3  10
   / \
  1   6

```

**Uses:**
- Ordered data with fast insert/search/delete (average case)
- Range queries by in-order traversal

**API notes:** TreeNode API plus ordered operations.

**TreeNode differences:** Inherits TreeNode but enforces ordering semantics.

**References:**
- [Binary search tree](https://en.wikipedia.org/wiki/Binary_search_tree)
- [Binary search tree (Princeton)](https://algs4.cs.princeton.edu/32bst/)

## AVL Tree (Tree::AvlTreeNode)

**Ruby type:** `Tree::AvlTreeNode` (require `tree/avltree`)

**Description:** A self-balancing binary search tree that maintains height
balance (difference of 1) for every node, keeping searches fast even in the
worst case.

**Motivation:** Prefer this when you want predictable lookup performance and
are willing to pay more on insert/delete for rebalancing.

**When not to use:** Avoid if inserts/deletes dominate and you prefer fewer
rotations (consider Red-Black).

**Structure:**

```text
      4
     / \
    2   6
   / \ / \
  1  3 5  7

```

**Uses:**
- Ordered data with strong balancing guarantees
- Faster lookups when reads dominate writes

**API notes:** TreeNode API plus rotations for balance.

**TreeNode differences:** Inherits TreeNode, adds rotations to maintain balance.

**References:**
- [AVL tree](https://en.wikipedia.org/wiki/AVL_tree)
- [AVL tree (USF)](https://www.cs.usfca.edu/~galles/visualization/AVLtree.html)

## Red-Black Tree (Tree::RedBlackTreeNode)

**Ruby type:** `Tree::RedBlackTreeNode` (require `tree/redblacktree`)

**Description:** A self-balancing binary search tree using node coloring to
ensure logarithmic height. It tends to rebalance less aggressively than AVL
trees, making updates cheaper on average.

**Motivation:** Choose this when inserts and deletes are frequent and you still
need guaranteed logarithmic performance.

**When not to use:** Avoid if your workload is read-heavy and you want tighter
height bounds (consider AVL).

**Structure:**

```text
      8(B)
     /    \
   4(R)  12(R)
   / \    / \
 2(B)6(B)10(B)14(B)

```

**Uses:**
- Ordered maps/sets (common in language runtimes)
- Balanced inserts/deletes with fewer rotations than AVL

**API notes:** TreeNode API plus color-based rebalancing.

**TreeNode differences:** Inherits TreeNode, adds coloring and rebalancing.

**References:**
- [Red–black tree](https://en.wikipedia.org/wiki/Red%E2%80%93black_tree)
- [Red–black tree (Princeton)](https://algs4.cs.princeton.edu/33balanced/)

## Treap (Tree::TreapNode)

**Ruby type:** `Tree::TreapNode` (require `tree/treap`)

**Description:** A randomized binary search tree that also maintains a heap
property on randomly assigned priorities. This gives expected logarithmic
height without explicit balancing logic.

**Motivation:** Use this when you want a simple, randomized balancing strategy
with good average performance.

**When not to use:** Avoid if you require deterministic balancing.

**Structure:**

```text
   key:5,p:10
    /       \
key:2,p:20  key:8,p:30

```

**Uses:**
- Ordered data with probabilistic balance
- Efficient split/merge operations

**API notes:** TreeNode API plus heap-priority invariants.

**TreeNode differences:** Inherits TreeNode, combines BST ordering with heap
priority constraints.

**References:**
- [Treap](https://en.wikipedia.org/wiki/Treap)

## Splay Tree (Tree::SplayTreeNode)

**Ruby type:** `Tree::SplayTreeNode` (require `tree/splaytree`)

**Description:** A self-adjusting binary search tree that splays recently
accessed nodes to the root, giving good amortized performance and favoring
frequently accessed keys.

**Motivation:** Use this when access patterns have locality and you want a
structure that adapts to hot keys over time.

**When not to use:** Avoid if you need strong worst-case guarantees per
operation.

**Structure:**

```text
    (after access)
       x
      / \
     A   B

```

**Uses:**
- Workloads with temporal locality
- Simple implementation with good amortized performance

**API notes:** TreeNode API plus splaying behavior on access.

**TreeNode differences:** Inherits TreeNode, uses splaying rotations on access.

**References:**
- [Splay tree](https://en.wikipedia.org/wiki/Splay_tree)

## Binary Heap (Tree::BinaryHeapNode)

**Ruby type:** `Tree::BinaryHeapNode` (require `tree/binaryheap`)

**Description:** A complete binary tree with the heap property (min-heap here),
where every parent is less than or equal to its children. The shape is fixed
to be complete, which makes array-based storage efficient.

**Motivation:** Use this for priority queues where you need fast access to the
minimum element.

**When not to use:** Avoid if you need ordered traversal or fast search.

**Structure:**

```text
       1
     /   \
    3     5
   / \   /
  7  9  6

```

**Uses:**
- Priority queues
- Scheduling and shortest path algorithms (Dijkstra, A*)

**API notes:** TreeNode API plus heap-specific operations. Traversal is not
ordered.

**TreeNode differences:** Inherits TreeNode, but traversal order is not sorted.
Only heap operations (peek/extract/insert) are semantically meaningful.

**References:**
- [Binary heap](https://en.wikipedia.org/wiki/Binary_heap)
- [Priority queue (Wikipedia)](https://en.wikipedia.org/wiki/Priority_queue)

## Binary Max-Heap (Tree::BinaryMaxHeapNode)

**Ruby type:** `Tree::BinaryMaxHeapNode` (require `tree/binarymaxheap`)

**Description:** A complete binary tree with the heap property (max-heap),
where every parent is greater than or equal to its children.

**Motivation:** Use this for priority queues where you need fast access to the
maximum element.

**When not to use:** Avoid if you need ordered traversal or fast search.

**Structure:**

```text
       9
     /   \
    7     6
   / \   /
  3  2  1

```

**Uses:**
- Priority queues (max priority)
- Top-K selection and streaming maxima

**API notes:** TreeNode API plus heap-specific operations. Traversal is not
ordered.

**TreeNode differences:** Inherits TreeNode, but traversal order is not sorted.
Only heap operations (peek/extract/insert) are semantically meaningful.

**References:**
- [Binary heap](https://en.wikipedia.org/wiki/Binary_heap)
- [Priority queue (Wikipedia)](https://en.wikipedia.org/wiki/Priority_queue)

## Fenwick Tree (Tree::FenwickTree)

**Ruby type:** `Tree::FenwickTree` (require `tree/fenwicktree`)

**Description:** A binary indexed tree represented internally as an array of
partial sums. It supports point updates and prefix/range sums in logarithmic
time with a compact implementation.

**Motivation:** Use this when you have frequent point updates and prefix/range
sum queries over a static-size array.

**When not to use:** Avoid if you need range updates or arbitrary aggregation.

**Structure:**

```text
Index: 1 2 3 4 5 6 7 8
Tree:  t1 t2 t3 t4 t5 t6 t7 t8

```

**Uses:**
- Fast prefix sums
- Frequency tables and cumulative counts
- Streaming analytics

**API notes:** Non-TreeNode; exposes Enumerable/Comparable and array-style
accessors where they map to array semantics.

**TreeNode differences:** Does not inherit TreeNode. Provides a TreeNode-like
subset (Enumerable/Comparable, array-style accessors, hash/JSON serialization)
where it maps to array-based semantics.

**References:**
- [Fenwick tree](https://en.wikipedia.org/wiki/Fenwick_tree)

## Segment Tree (Tree::SegmentTree)

**Ruby type:** `Tree::SegmentTree` (require `tree/segmenttree`)

**Description:** A tree over array segments, enabling range queries (sum) and
point updates in logarithmic time. The segment tree can be extended to support
other associative operations beyond sums.

**Motivation:** Use this when you need fast range queries and point updates and
want a structure that generalizes beyond prefix sums.

**When not to use:** Avoid if you only need prefix sums (Fenwick is simpler).

**Structure:**

```text
           [0..7]
         /        \
     [0..3]      [4..7]
     /   \        /   \
  [0..1][2..3] [4..5][6..7]

```

**Uses:**
- Range sum queries
- Interval analytics and windowed aggregation

**API notes:** Non-TreeNode; exposes Enumerable/Comparable and array-style
accessors where they map to array semantics.

**TreeNode differences:** Does not inherit TreeNode. Provides a TreeNode-like
subset (Enumerable/Comparable, array-style accessors, hash/JSON serialization)
where it maps to array-based semantics.

**References:**
- [Segment tree](https://en.wikipedia.org/wiki/Segment_tree)

## B-Tree (Tree::BTree)

**Ruby type:** `Tree::BTree` (require `tree/btree`)

**Description:** A balanced multi-way search tree optimized for block storage
with multiple keys per node. This implementation stores ordered key/value pairs
in each node to reduce tree height.

**Motivation:** Use this when datasets are large and you want shallow trees
that minimize node traversals.

**When not to use:** Avoid for tiny datasets where simpler BSTs are sufficient.

**Structure:**

```text
        [10|20|30]
       /   |   |  \
   [1|5] [12|18] [22|26] [35|40]

```

**Uses:**
- Database indexes
- Filesystem metadata indexes
- Large ordered datasets with fewer disk seeks

**API notes:** Non-TreeNode; exposes traversal and serialization suited to
multi-entry nodes.

**TreeNode differences:** Does not inherit TreeNode. Provides traversal and
serialization helpers that align with multi-entry node semantics.

**References:**
- [B-tree](https://en.wikipedia.org/wiki/B-tree)
- [B-tree (USF)](https://www.cs.usfca.edu/~galles/visualization/BTree.html)

## Trie (Tree::TrieNode)

**Ruby type:** `Tree::TrieNode` (require `tree/trie`)

**Description:** A prefix tree where edges represent characters and paths form
keys (words). It trades extra space for fast prefix queries and deterministic
lookups by character.

**Motivation:** Use this for prefix searches, autocomplete, and dictionary-like
matching where partial keys are common.

**When not to use:** Avoid if memory is tight or keys are large/uniform.

**Structure:**

```text
  (root)
   / \
  c   d
  |
  a
  |
  t

```

**Uses:**
- Autocomplete
- Prefix lookup and dictionary membership
- Routing tables and spell-checking

**API notes:** TreeNode API tailored to prefix semantics.

**TreeNode differences:** Inherits TreeNode, but keys are represented by paths,
so node content and traversal are tailored to prefix semantics.

**References:**
- [Trie](https://en.wikipedia.org/wiki/Trie)
- [Trie (Princeton)](https://algs4.cs.princeton.edu/52trie/)

[toc-bst]: #binary-search-tree-treebinarysearchtreenode
[toc-rbt]: #red-black-tree-treeredblacktreenode
[toc-maxheap]: #binary-max-heap-treebinarymaxheapnode
