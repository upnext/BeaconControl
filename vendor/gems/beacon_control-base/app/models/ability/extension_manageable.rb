###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Ability
  module ExtensionManageable
    extend ActiveSupport::Concern

    included do
      def allowed_extension?(role, extension)
        return false if disallowed_extension?(role, extension)
        self.class.allowed_extensions_for(role).any? do |klass|
          klass.registered_name == extension.name
        end
      end

      def disallowed_extension?(role, extension)
        self.class.disallowed_extensions_for(role).any? do |klass|
          klass.registered_name == extension.name
        end
      end
    end

    class_methods do
      # @param [Proc] block
      def allow_extension(role, &block)
        klass = block.call rescue nil
        allowed_extensions_for(role) << klass if klass
      end

      # @param [Proc] block
      def disallow_extension(role, &block)
        klass = block.call rescue nil
        disallowed_extensions_for(role) << klass if klass
      end

      # @return [Hash<String,Array<Class>>]
      def allowed_extensions
        @allowed_extensions ||= {}
      end

      # @return [Array<Class>]
      def allowed_extensions_for(role)
        allowed_extensions[role] ||= []
      end

      # @return [Hash<String,Array<Class>>]
      def disallowed_extensions
        @disallowed_extensions ||= {}
      end

      # @return [Array<Class>]
      def disallowed_extensions_for(role)
        disallowed_extensions[role] ||= []
      end
    end
  end
end