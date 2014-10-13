require 'json'

# Provides utility methods to convert a {Tree::TreeNode} to and from
# JSON[http://flori.github.com/json/].
module Tree::Utils::JSONConverter

  def self.included(base)
    base.extend(ClassMethods)
  end

  # @!group Converting to/from JSON

  # Creates a JSON ready Hash for the #to_json method.
  #
  # @author Eric Cline (https://github.com/escline)
  # @since 0.8.3
  #
  # @return A hash based representation of the JSON
  #
  # Rails uses JSON in ActiveSupport, and all Rails JSON encoding goes through +as_json+.
  #
  # @see #to_json
  # @see http://stackoverflow.com/a/6880638/273808
  def as_json(options = {})

    json_hash = {
      "name"         => name,
      "content"      => content,
      JSON.create_id => self.class.name
    }

    if has_children?
      json_hash["children"] = children
    end

    return json_hash

  end

  # Creates a JSON representation of this node including all it's children.
  # This requires the JSON gem to be available, or else the operation fails with
  # a warning message.  Uses the Hash output of #as_json method.
  #
  # @author Dirk Breuer (http://github.com/railsbros-dirk)
  # @since 0.7.0
  #
  # @return The JSON representation of this subtree.
  #
  # @see ClassMethods#json_create
  # @see #as_json
  # @see http://flori.github.com/json
  def to_json(*a)
    as_json.to_json(*a)
  end

  # ClassMethods for the {JSONConverter} module.  Will become class methods in the +include+ target.
  module ClassMethods
    # Helper method to create a Tree::TreeNode instance from the JSON hash
    # representation.  Note that this method should *NOT* be called directly.
    # Instead, to convert the JSON hash back to a tree, do:
    #
    #   tree = JSON.parse(the_json_hash)
    #
    # This operation requires the {JSON gem}[http://flori.github.com/json/] to
    # be available, or else the operation fails with a warning message.
    #
    # @author Dirk Breuer (http://github.com/railsbros-dirk)
    # @since 0.7.0
    #
    # @param [Hash] json_hash The JSON hash to convert from.
    #
    # @return [Tree::TreeNode] The created tree.
    #
    # @see #to_json
    # @see http://flori.github.com/json
    def json_create(json_hash)

      node = new(json_hash["name"], json_hash["content"])

      json_hash["children"].each do |child|
        node << child
      end if json_hash["children"]

      return node

    end
  end
end
