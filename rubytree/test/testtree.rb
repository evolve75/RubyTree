#!/usr/bin/env ruby

require 'test/unit'
require 'tree'
require 'person'

# Test class for the Tree node.
class TC_TreeTest < Test::Unit::TestCase

    def setup
        @root = Tree::TreeNode.new("ROOT", "Root Node")

        @child1 = Tree::TreeNode.new("Child1", "Child Node 1")
        @child2 = Tree::TreeNode.new("Child2", "Child Node 2")
        @child3 = Tree::TreeNode.new("Child3", "Child Node 3")
        @child4 = Tree::TreeNode.new("Child31", "Grand Child 1")

    end

    def loadChildren
        @root << @child1
        @root << @child2
        @root << @child3 << @child4
    end

    def teardown
        @root = nil
    end

    def test_root_setup
        assert_not_nil(@root, "Root cannot be nil")
        assert_nil(@root.parent, "Parent of root node should be nil")
        assert_not_nil(@root.name, "Name should not be nil")
        assert_equal("ROOT", @root.name, "Name should be 'ROOT'")
        assert_equal("Root Node", @root.content, "Content should be 'Root Node'")
        assert(@root.isRoot?, "Should identify as root")
        assert(!@root.hasChildren?, "Cannot have any children")
        assert_equal(1, @root.size, "Number of nodes should be one")

        assert_raise(RuntimeError) { Tree::TreeNode.new(nil) }
    end

    def test_root
        loadChildren

        assert_same(@root, @root.root, "Root's root is self")
        assert_same(@root, @child1.root, "Root should be ROOT")
        assert_same(@root, @child4.root, "Root should be ROOT")
    end

    def test_siblings
        loadChildren

        siblings = []
        @child1.siblings { |sibling| siblings << sibling}
        assert_equal(2, siblings.length, "Should have two siblings")
        assert(siblings.include?(@child2), "Should have 2nd child as sibling")
        assert(siblings.include?(@child3), "Should have 3rd child as sibling")

        siblings.clear
        siblings = @child1.siblings
        assert_equal(2, siblings.length, "Should have two siblings")

        siblings.clear
        @child4.siblings {|sibling| siblings << sibling}
        assert(siblings.empty?, "Should not have any children")

    end

    def test_add
        assert(!@root.hasChildren?, "Should not have any children")

        @root.add(@child1)

        @root << @child2

        assert(@root.hasChildren?, "Should have children")
        assert_equal(3, @root.size, "Should have three nodes")

        @root << @child3 << @child4

        assert_equal(5, @root.size, "Should have five nodes")
        assert_equal(2, @child3.size, "Should have two nodes")

        assert_raise(RuntimeError) { @root.add(Tree::TreeNode.new(@child1.name)) }

    end

    def test_remove
        @root << @child1
        @root << @child2

        assert(@root.hasChildren?, "Should have children")
        assert_equal(3, @root.size, "Should have three nodes")

        @root.remove!(@child1)
        assert_equal(2, @root.size, "Should have two nodes")
        @root.remove!(@child2)

        assert(!@root.hasChildren?, "Should have no children")
        assert_equal(1, @root.size, "Should have one node")

        @root << @child1
        @root << @child2

        assert(@root.hasChildren?, "Should have children")
        assert_equal(3, @root.size, "Should have three nodes")

        @root.removeAll!

        assert(!@root.hasChildren?, "Should have no children")
        assert_equal(1, @root.size, "Should have one node")

    end

    def test_removeAll
        loadChildren
        assert(@root.hasChildren?, "Should have children")
        @root.removeAll!

        assert(!@root.hasChildren?, "Should have no children")
        assert_equal(1, @root.size, "Should have one node")
    end

    def test_removeFromParent
        loadChildren
        assert(@root.hasChildren?, "Should have children")

        child1 = @root[0]
        assert_not_nil(child1, "Child 1 should exist")
        assert_same(@root, child1.root, "Child 1's root should be ROOT")
        assert(@root.include?(child1), "root should have child1")
        child1.removeFromParent!
        assert_same(child1, child1.root, "Child 1's root should be self")
        assert(!@root.include?(child1), "root should not have child1")

        child1.removeFromParent!
        assert_same(child1, child1.root, "Child 1's root should still be self")
    end

    def test_children
        loadChildren

        assert(@root.hasChildren?, "Should have children")
        assert_equal(5, @root.size, "Should have four nodes")
        assert(@child3.hasChildren?, "Should have children")

        children = []
        for child in @root.children
            children << child
        end

        assert_equal(3, children.length, "Should have three direct children")
        assert(!children.include?(@root), "Should not have root")
        assert(children.include?(@child1), "Should have child 1")
        assert(children.include?(@child2), "Should have child 2")
        assert(children.include?(@child3), "Should have child 3")
        assert(!children.include?(@child4), "Should not have child 4")

        children.clear
        children = @root.children
        assert_equal(3, children.length, "Should have three children")

    end

    def test_find
        loadChildren
        foundNode = @root.find { |node| node == @child2}
        assert_same(@child2, foundNode, "The node should be Child 2")

        foundNode = @root.find { |node| node == @child4}
        assert_same(@child4, foundNode, "The node should be Child 4")

        foundNode = @root.find { |node| node.name == "Child31" }
        assert_same(@child4, foundNode, "The node should be Child 4")
        foundNode = @root.find { |node| node.name == "NOT PRESENT" }
        assert_nil(foundNode, "The node should not be found")
    end

    def test_each
        loadChildren
        assert(@root.hasChildren?, "Should have children")
        assert_equal(5, @root.size, "Should have five nodes")
        assert(@child3.hasChildren?, "Should have children")

        nodes = []
        @root.each { |node| nodes << node }

        assert_equal(5, nodes.length, "Should have FIVE NODES")
        assert(nodes.include?(@root), "Should have root")
        assert(nodes.include?(@child1), "Should have child 1")
        assert(nodes.include?(@child2), "Should have child 2")
        assert(nodes.include?(@child3), "Should have child 3")
        assert(nodes.include?(@child4), "Should have child 4")
    end

    def test_parent
        loadChildren
        assert_nil(@root.parent, "Root's parent should be nil")
        assert_equal(@root, @child1.parent, "Parent should be root")
        assert_equal(@root, @child3.parent, "Parent should be root")
        assert_equal(@child3, @child4.parent, "Parent should be child3")
        assert_equal(@root, @child4.parent.parent, "Parent should be root")
    end

    def test_indexed_access
        loadChildren
        assert_equal(@child1, @root[0], "Should be the first child")
        assert_equal(@child4, @root[2][0], "Should be the grandchild")
        assert_nil(@root["TEST"], "Should be nil")
        assert_raise(RuntimeError) { @root[nil] }
    end

    def test_printTree
        loadChildren
        #puts
        #@root.printTree
    end

    def test_dump
        loadChildren

        pers = Person.new("John", "Doe")
        #@root.content = pers

        data = Marshal.dump(@root)

        newRoot = Marshal.load(data)
        assert(newRoot.isRoot?, "Must be a root node")
        assert_equal("ROOT", newRoot.name, "Must identify as ROOT")
        assert_equal("Root Node", newRoot.content, "Must have root's content")
        #assert_equal(pers.first, newRoot.content.first, "Must be the same content")
        assert_equal(@child4.name, newRoot['Child3']['Child31'].name, "Must be the grand child")
    end

    def test_collect
        loadChildren
        collectArray = @root.collect do |node|
            node.content = "abc"
            node
        end
        collectArray.each {|node| assert_equal("abc", node.content, "Should be 'abc'")}
    end

    def test_freezeTree
        loadChildren
        @root.content = "ABC"
        assert_equal("ABC", @root.content, "Content should be 'ABC'")
        @root.freezeTree!
        assert_raise(TypeError) {@root.content = "123"}
        assert_raise(TypeError) {@root[0].content = "123"}
    end

    def test_content
        pers = Person.new("John", "Doe")
        @root.content = pers
        assert_same(pers, @root.content, "Content should be the same")
    end
end
