# tree.rb
#
# $Revision$ by $Author$
# $Name$
#
# = tree.rb - Generic Tree implementation
#
# Provides a generic tree data structure with ability to
# store keyed node elements in the tree. The implementation
# mixes in the Enumerable module.
#
# Author:: Anupam Sengupta (anupamsg@gmail.com)
#

# Copyright (c) 2006, 2007 Anupam Sengupta
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# - Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# - Redistributions in binary form must reproduce the above copyright notice, this
#   list of conditions and the following disclaimer in the documentation and/or
#   other materials provided with the distribution.
#
# - Neither the name of the organization nor the names of its contributors may
#   be used to endorse or promote products derived from this software without
#   specific prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# This module provides a TreeNode class which is the primary class for all
# nodes represented in the Tree.
# This module mixes in the Enumerable module.
module Tree

  # == TreeNode Class Description
  #
  # The node class for the tree representation. the nodes are named and have a
  # place-holder for the node data (i.e., the `content' of the node). The node
  # names are expected to be unique.  In addition, the node provides navigation
  # methods to traverse the tree.
  #
  # The nodes can have any number of child nodes attached to it. Note that while
  # this implementation does not support directed graphs, the class itself makes
  # no restrictions on associating a node's CONTENT with multiple parent nodes.
  #
  #
  # == Example
  #
  #  The following code-snippet implements this tree structure:
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
  # require 'tree'
  #
  # myTreeRoot = Tree::TreeNode.new("ROOT", "Root Content")
  #
  # myTreeRoot << Tree::TreeNode.new("CHILD1", "Child1 Content") << Tree::TreeNode.new("GRANDCHILD1", "GrandChild1 Content")
  #
  # myTreeRoot << Tree::TreeNode.new("CHILD2", "Child2 Content")
  #
  # myTreeRoot.printTree
  #
  # child1 = myTreeRoot["CHILD1"]
  #
  # grandChild1 = myTreeRoot["CHILD1"]["GRANDCHILD1"]
  #
  # siblingsOfChild1Array = child1.siblings
  #
  # immediateChildrenArray = myTreeRoot.children
  #
  # # Process all nodes
  #
  # myTreeRoot.each { |node| node.content.reverse }
  #
  # myTreeRoot.remove!(child1) # Remove the child
  class TreeNode
    include Enumerable

    attr_reader :content, :name, :parent
    attr_writer :content

    @@fieldSep = '|'
    @@recordSep = "\n"

    # Constructor which expects the name of the node
    #
    # Name of the node is expected to be unique across the
    # tree.
    #
    # The content can be of any type, and is defaulted to _nil_.
    def initialize(name, content = nil)

      raise "Node name HAS to be provided" if name == nil

      @name = name
      @content = content

      self.setAsRoot!

      @childrenHash = Hash.new
      @children = []
    end

    # Print the string representation of this node.
    def to_s

      "Node Name: #{@name}" +
        " Content: " + (@content || "<Empty>") +
        " Parent: " + (isRoot?()  ? "<None>" : @parent.name) +
        " Children: #{@children.length}" +
        " Total Nodes: #{size()}"

    end

    # Returns an array of ancestors in reversed order (the first element is the
    # immediate parent). Returns nil if this is a root node.
    def ancestors
      return nil if isRoot?

      ancestorsArray = []
      prevParent = self.parent
      while (prevParent)
        ancestorsArray << prevParent
        prevParent = prevParent.parent
      end

      ancestorsArray
    end

    # Protected method to set the parent node.
    # This method should NOT be invoked by client code.
    def parent=(parent)
      @parent = parent
    end

    # Convenience synonym for Tree#add method.  This method allows a convenient
    # method to add children hierarchies in the tree.
    #
    # E.g. root << child << grand_child
    def <<(child)
      add(child)
    end

    # Adds the specified child node to the receiver node.  The child node's
    # parent is set to be the receiver.  The child is added as the last child in
    # the current list of children for the receiver node.
    def add(child)
      raise "Child already added" if @childrenHash.has_key?(child.name)

      @childrenHash[child.name]  = child
      @children << child
      child.parent = self
      return child

    end

    # Removes the specified child node from the receiver node.  The removed
    # children nodes are orphaned but available if an alternate reference
    # exists.
    #
    # Returns the child node.
    def remove!(child)
      @childrenHash.delete(child.name)
      @children.delete(child)
      child.setAsRoot! unless child == nil
      return child
    end

    # Removes this node from its parent. If this is the root node, then does
    # nothing.
    def removeFromParent!
      @parent.remove!(self) unless isRoot?
    end

    # Removes all children from the receiver node.
    def removeAll!
      for child in @children
        child.setAsRoot!
      end
      @childrenHash.clear
      @children.clear
      self
    end

    # Indicates whether this node has any associated content.
    def hasContent?
      @content != nil
    end

    # Private method which sets this node as a root node.
    def setAsRoot!
      @parent = nil
    end

    # Indicates whether this node is a root node. Note that
    # orphaned children will also be reported as root nodes.
    def isRoot?
      @parent == nil
    end

    # Indicates whether this node has any immediate child nodes.
    def hasChildren?
      @children.length != 0
    end

    # Indicates whether this node is a 'leaf' - i.e., one without
    # any children
    def isLeaf?
      !hasChildren?
    end

    # Returns an array of all the immediate children.  If a block is given,
    # yields each child node to the block.
    def children
      if block_given?
        @children.each {|child| yield child}
      else
        @children
      end
    end

    # Returns the first child of this node. Will return nil if no children are
    # present.
    def firstChild
      children.first
    end

    # Returns the last child of this node. Will return nil if no children are
    # present.
    def lastChild
      children.last
    end

    # Returns every node (including the receiver node) from the tree to the
    # specified block. The traversal is depth first and from left to right.
    def each &block
      yield self
      children { |child| child.each(&block) }
    end

    # Yields all leaf nodes from this node to the specified block. May yield this
    # node as well if this is a leaf node.  Leaf traversal is left to right.
    def each_leaf &block
      self.each { |node| yield(node) if node.isLeaf? }
    end

    # Returns the requested node from the set of immediate children.
    #
    # If the key is _numeric_, then the in-sequence array of children is
    # accessed (see Tree#children).  If the key is not _numeric_, then it is
    # assumed to be the *name* of the child node to be returned.
    def [](key)
      raise "Key needs to be provided" if key == nil

      if key.kind_of?(Integer)
        @children[key]
      else
        @childrenHash[key]
      end
    end

    # Returns the total number of nodes in this tree, rooted at the receiver
    # node.
    def size
      @children.inject(1) {|sum, node| sum + node.size}
    end

    # Convenience synonym for Tree#size
    def length
      size()
    end

    # Pretty prints the tree starting with the receiver node.
    def printTree(level = 0)

      if isRoot?
        print "*"
      else
        print "|" unless parent.isLastSibling?
        print(' ' * (level - 1) * 4)
        print(isLastSibling? ? "+" : "|")
        print "---"
        print(hasChildren? ? "+" : ">")

#        print((' ' * level)  + "|--" + (hasChildren? ? "+" : ">"))
      end

      puts " #{name}"

      children { |child| child.printTree(level + 1)}
    end

    # Returns the root for this tree. Root's root is itself.
    def root
      root = self
      root = root.parent while !root.isRoot?
      root
    end

    # Returns the first sibling for this node. If this is the root node, returns
    # itself.
    def firstSibling
      if isRoot?
        self
      else
        parent.children.first
      end
    end

    # Returns true if this node is the first sibling.
    def isFirstSibling?
      firstSibling == self
    end

    # Returns the last sibling for this node.  If this node is the root, returns
    # itself.
    def lastSibling
      if isRoot?
        self
      else
        parent.children.last
      end
    end

    # Returns true if his node is the last sibling
    def isLastSibling?
      lastSibling == self
    end

    # Returns an array of siblings for this node.
    # If a block is provided, yields each of the sibling
    # nodes to the block. The root always has nil siblings.
    def siblings
      return nil if isRoot?
      if block_given?
        for sibling in parent.children
          yield sibling if sibling != self
        end
      else
        siblings = []
        parent.children {|sibling| siblings << sibling if sibling != self}
        siblings
      end
    end

    # Returns true if this node is the only child of its parent
    def isOnlyChild?
      parent.children.size == 1
    end

    # Returns the next sibling for this node. Will return nil if no subsequent
    # node is present.
    def nextSibling
      if myidx = parent.children.index(self)
        parent.children.at(myidx + 1)
      end
    end

    # Returns the previous sibling for this node. Will return nil if no
    # subsequent node is present.
    def previousSibling
      if myidx = parent.children.index(self)
        parent.children.at(myidx - 1) if myidx > 0
      end
    end

    # Provides a comparision operation for the nodes. Comparision
    # is based on the natural character-set ordering for the
    # node names.
    def <=>(other)
      return +1 if other == nil
      self.name <=> other.name
    end

    # Freezes all nodes in the tree
    def freezeTree!
      each {|node| node.freeze}
    end

    # Creates a dump representation and returns the same as a string
    def createDumpRep
      strRep = String.new
      strRep << @name << @@fieldSep << (isRoot? ? @name : @parent.name)
      strRep << @@fieldSep << Marshal.dump(@content) << @@recordSep
    end

    def _dump(depth)
      strRep = String.new
      each {|node| strRep << node.createDumpRep}
      strRep
    end

    # Loads a dump representation of the tree from the specified string
    def TreeNode.loadDumpRep(str)
      nodeHash = Hash.new
      rootNode = nil
      str.split(@@recordSep).each do |line|
        name, parent, contentStr = line.split(@@fieldSep)
        content = Marshal.load(contentStr)
        currentNode = Tree::TreeNode.new(name, content)
        nodeHash[name] = currentNode
        if name != parent  # Do for a child node
          nodeHash[parent].add(currentNode)
        else
          rootNode = currentNode
        end
      end
      rootNode
    end

    # Loads a dump representation of the tree from the specified string.
    def TreeNode._load(str)
      loadDumpRep(str)
    end

    protected :parent=, :setAsRoot!
    private_class_method :loadDumpRep

  end
end

if __FILE__ == $0
  root   = Tree::TreeNode.new("ROOT")
  child1 = Tree::TreeNode.new("CHILD1")
  child2 = Tree::TreeNode.new("CHILD2")
  child3 = Tree::TreeNode.new("CHILD3")
  grandchild1 = Tree::TreeNode.new("GRANDCHILD1")
  root << child1 << grandchild1
  root << child2
  root << child3

  puts child1.nextSibling
  root.printTree
end

# $Log$
# Revision 1.12  2007/07/17 03:39:28  anupamsg
# Moved the CVS Log keyword to end of the files.
#
