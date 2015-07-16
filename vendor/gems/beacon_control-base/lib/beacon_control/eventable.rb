###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl::Eventable
  extend ActiveSupport::Concern

  included do
    def trigger(name)
      self.class.callbacks_for(name).each do |cb|
        case cb
        when Symbol, String then send(cb)
        when Proc then instance_exec(&cb)
        else
        end
      end
    end

    def event(event)
      trigger :"before_#{event}"
      yield
      trigger :"after_#{event}"
    end

    def transaction(name, &block)
      event(:"#{name}_transaction") do
        ActiveRecord::Base.transaction(&block)
      end
    end
  end

  class_methods do
    def callbacks
      @callbacks ||= {}
    end

    def callbacks_for(name)
      callbacks[name] ||= []
    end

    def on(event, method=nil, &block)
      callbacks_for(event) << (method ? method : block)
    end
  end
end