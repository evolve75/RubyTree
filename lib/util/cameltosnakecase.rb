# cameltosnakecase.rb - This file is part of the RubyTree package.
#
# = cameltosnakecase.rb - Generic implementation of the CamelCase to snake_case method conversion.
#
# Provides a generic mix-in module to help with converting calls to
# CamelCase method names to the snake_case names.  This is primarily
# to assist in deprecating old method names which used CamelCase to
# the new snake_case names (in order to follow the Ruby conventions).
#
# Author:: Anupam Sengupta (anupamsg@gmail.com)
#
# Copyright (c) 2012 Anupam Sengupta
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

# This module provides a mix-in for converting calls to non-existent
# CamelCase methods names to the existing snake_case method names in
# the class that this is mixed into.
module CamelToSnakeCase

    # Allow the deprecated CamelCase method names.  Display a warning.
    def method_missing(meth, *args, &blk)
      if self.respond_to?(new_method_name = underscore(meth))
        begin
          require 'structured_warnings'   # To enable a nice way of deprecating of the invoked CamelCase method.
          warn DeprecatedMethodWarning, "The camelCased methods are deprecated. Please use #{new_method_name} instead of #{meth}"

        rescue LoadError
          # Oh well. Will use the standard Kernel#warn.  Behavior will be identical.
          warn "#{meth}() method is deprecated. Please use #{new_method_name} instead."

        ensure                  # Invoke the method now.
          return send(new_method_name, *args, &blk)
        end

      else
        super
      end
    end

    # Convert a CamelCasedWord to a underscore separated camel_cased_word.
    #
    # Just copied from ActiveSupport::Inflector because it is only needed
    # aliasing deprecated methods.
    def underscore(camel_cased_word)
      word = camel_cased_word.to_s.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end

    private :underscore

end
