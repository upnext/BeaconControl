###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require 'application_controller' unless defined?(::ApplicationController)

class ApplicationController
  module ParamsExtendable
    extend ActiveSupport::Concern

    DirectParamsOverriding = Class.new(StandardError)

    included do
      class << self
        def extendable(override, as: nil)
          override = override.to_s
          if override == 'params' && as.present?
            define_method(as) { params }
          elsif override == 'params'
            raise DirectParamsOverriding.new('please provide as: parameter to create wrapper method')
          else
            as = override
          end
          name = :"__extendable__#{as}__"
          alias_method name, as
          define_method(as) do
            basic = override == 'params' ? {} : send(name)
            data = self.class.extendable_params_for(as)
            extended = send(override).
              fetch(*data[:fetch], {}).
              permit(*data[:params])
            basic.deep_merge(extended).with_indifferent_access
          end
        end

        # @param [String] name - method name
        # @param [Hash|Array] params - data to add
        def extend_params(name, fetch:, permit:)
          store = extendable_params_for(name)
          store[:fetch] = (store[:fetch] + [fetch]).uniq
          store[:params] = (store[:params] + permit).uniq
        end

        private def extensions_config_store
          @extensions_config_store ||= {}
        end

        public def extendable_params_for(name)
          extensions_config_store[name] ||= { fetch: [], params: [] }
        end
      end
    end
  end
end
