# structure_methods.rb - This file is part of the RubyTree package.
#
# Copyright (c) 2006-2026 Anupam Sengupta. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# - Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# - Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# - Neither the name of the organization nor the names of its contributors may
#   be used to endorse or promote products derived from this software without
#   specific prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# frozen_string_literal: true

module Tree
  module Utils
    # Provides structure-modification helpers for TreeNode.
    module TreeStructureHandler
      # Convenience synonym for {Tree::TreeNode#add} method.
      def <<(child)
        add(child)
      end

      # Adds the specified child node to this node.
      def add(child, at_index = -1)
        # Only handles the immediate child scenario
        raise ArgumentError, 'Attempting to add a nil node' unless child

        raise ArgumentError, 'Attempting add node to itself' if equal?(child)

        raise ArgumentError, 'Attempting add root as a child' if child.equal?(root)

        if (ancestors = parentage) && ancestors.include?(child)
          raise ArgumentError, 'Attempting add ancestor as a child'
        end

        # Lazy man's unique test, won't test if children of child are unique in
        # this tree too.
        raise "Child #{child.name} already added!"\
              if @children_hash.include?(child.name)

        child.parent&.remove! child # Detach from the old parent

        if insertion_range.include?(at_index)
          @children.insert(at_index, child)
        else
          raise 'Attempting to insert a child at a non-existent location'\
                " (#{at_index}) "\
                'when only positions from '\
                "#{insertion_range.min} to #{insertion_range.max} exist."
        end

        @children_hash[child.name] = child
        child.parent = self
        invalidate_size_cache_upwards!
        child
      end

      # Return a range of valid insertion positions.  Used in the #add method.
      def insertion_range
        max = @children.size
        min = -(max + 1)
        min..max
      end

      # Renames the node and updates the parent's reference to it
      def rename(new_name)
        old_name = @name

        if root?
          self.name = new_name
        else
          @parent.rename_child old_name, new_name
        end

        old_name
      end

      # Renames the specified child node
      def rename_child(old_name, new_name)
        raise ArgumentError, "Invalid child name specified: #{old_name}"\
              unless @children_hash.key?(old_name)

        raise ArgumentError, "Child name already exists: #{new_name}"\
              if @children_hash.key?(new_name)

        @children_hash[new_name] = @children_hash.delete(old_name)
        @children_hash[new_name].name = new_name
      end

      # Replaces the specified child node with another child node on this node.
      def replace!(old_child, new_child)
        child_index = @children.find_index(old_child)

        old_child = remove! old_child
        add new_child, child_index

        old_child
      end

      # Replaces the node with another node
      def replace_with(node)
        @parent.replace!(self, node)
      end

      # Removes the specified child node from this node.
      def remove!(child)
        return nil unless child

        @children_hash.delete(child.name)
        @children.delete(child)
        child.set_as_root!
        invalidate_size_cache_upwards!
        child
      end

      # Protected method to set the parent node for this node.
      def parent=(parent) # :nodoc:
        @parent = parent
        @node_depth = nil
        clear_root_cache!
        invalidate_size_cache_upwards!
      end

      # Removes this node from its parent. This node becomes the new root for its
      # subtree.
      def remove_from_parent!
        @parent.remove!(self) unless root?
      end

      # Removes all children from this node.
      def remove_all!
        @children.each do |child|
          child.remove_all!
          child.set_as_root!
        end

        @children_hash.clear
        @children.clear
        invalidate_size_cache_upwards!
        self
      end

      # Protected method which sets this node as a root node.
      def set_as_root! # :nodoc:
        self.parent = nil
      end

      # Freezes all nodes in the (sub)tree rooted at this node.
      def freeze_tree!
        each(&:freeze)
      end

      def clear_root_cache!
        @root_cache = nil
        return unless @children

        children_array.each do |child|
          child&.__send__(:clear_root_cache!)
        end
      end

      def invalidate_size_cache_upwards!
        node = self
        while node
          node.instance_variable_set(:@node_size, nil)
          node = node.parent
        end
      end

      private :insertion_range, :clear_root_cache!, :invalidate_size_cache_upwards!
      protected :parent=, :set_as_root!
    end
  end
end
