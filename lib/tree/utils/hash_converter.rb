module Tree::Utils::HashConverter

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    # Factory method builds a {Tree::TreeNode} from a +Hash+.
    #
    # This method will interpret each key of your +Hash+ as a {Tree::TreeNode}.
    # Nested hashes are expected and child nodes will be added accordingly. If
    # a hash key is a single value that value will be used as the name for the
    # node.  If a hash key is an Array, both node name and content will be
    # populated.
    #
    # A leaf element of the tree should be represented as a hash key with
    # corresponding value nil or {}.
    #
    # @example 
    #   TreeNode.from_hash({:A => {:B => {}, :C => {:D => {}, :E => {}}}})
    #   # would be parsed into the following tree structure:
    #   #    A
    #   #   / \
    #   #  B   C
    #   #     / \
    #   #    D   E
    #
    #   # The same tree would result from this nil-terminated Hash
    #   {:A => {:B => nil, :C => {:D => nil, :E => nil}}}
    #
    #   # A tree with equivalent structure but with content present for
    #   # nodes A and D could be built from a hash like this:
    #   {[:A, "A content"] => {:B => {}, :C => {[:D, "D content"] => {}, :E => {}}}}
    #
    # @author Jen Hamon (http://www.github.com/jhamon)
    # @param [Hash] hash Hash to build tree from.
    # @return [Tree::TreeNode] The {Tree::TreeNode} instance representing the root of your tree.
    #
    # @raise [ArgumentError] This exception is raised if a non-Hash is passed.
    # @raise [ArgumentError] This exception is raised if the hash has multiple top-level elements.
    # @raise [ArgumentError] This exception is raised if the hash contains values that are not hashes or nils.
    def from_hash(hash)
      raise ArgumentError, "Argument must be a type of hash" unless hash.is_a?(Hash)
      raise ArgumentError, "Hash must have one top-level element" if hash.size != 1

      root, children = hash.first

      unless [Hash, NilClass].include?(children.class)
        raise ArgumentError, "Invalid child. Must be nil or hash."
      end

      node = self.new(*root)
      node.add_from_hash(children) unless children.nil?
      node
    end
  end

    # Instantiate and insert child nodes from data in a Ruby +Hash+
    #
    # This method is used in conjunction with from_hash to provide a
    # convenient way of building and inserting child nodes present in a Ruby
    # hashes.
    #
    # This method will instantiate a node instance for each top-
    # level key of the input hash, to be inserted as children of the receiver
    # instance.
    #
    # Nested hashes are expected and further child nodes will be created and
    # added accordingly. If a hash key is a single value that value will be
    # used as the name for the node.  If a hash key is an Array, both node
    # name and content will be populated.
    #
    # A leaf element of the tree should be represented as a hash key with
    # corresponding value nil or {}.
    # 
    # @example
    #   root = Tree::TreeNode.new(:A, "Root content!")
    #   root.add_from_hash({:B => {:D => {}}, [:C, "C content!"] => {}})
    #
    # @author Jen Hamon (http://www.github.com/jhamon)
    # @param [Hash] children The hash of child subtrees.
    # @raise [ArgumentError] This exception is raised if a non-hash is passed.
    # @return [Array] Array of child nodes added
    def add_from_hash(children)
      raise ArgumentError, "Argument must be a type of hash" unless children.is_a?(Hash)

      child_nodes = []
      children.each do |child, grandchildren|
        child_node = self.class.from_hash({child => grandchildren})
        child_nodes << child_node
        self << child_node
      end

      child_nodes
    end
end