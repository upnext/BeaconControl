module AsyncValue
  extend ActiveSupport::Concern

  included do
    def vendor_callback(mth)
      current_vendor = self.instance_exec(&self.class.vendor_for_async_callback).vendor.to_s
      Rails.logger.info "Current vendor for async check: #{ current_vendor.inspect }"
      hash = self.class.async_vendors
      hash[current_vendor] && hash[current_vendor]["#{mth}"]
    end
  end

  module ClassMethods
    def async_vendors
      @async_vendors ||= {}.with_indifferent_access
    end

    def async_value(mth, opts={})
      file, line = caller.first.split(':', 2)
      mod_name = :"Async#{mth.to_s.camelize}"
      opts = opts.with_indifferent_access
      config_key = opts.fetch(:config_key, mth)
      vendor = opts.fetch(:vendor).to_s
      beacon = opts.fetch(:beacon)
      cast = opts.fetch(:cast, :to_i)
      create_module(mth, mod_name, file, line) unless const_defined?(mod_name)

      hash = async_vendors[vendor] ||= {}.with_indifferent_access
      hash[mth.to_s] ||= AsyncVendorCallback.new(vendor, beacon, cast, mth, config_key)

      @vendor_for_async_callback = beacon unless @vendor_for_async_callback
    end

    def vendor_for_async_callback
      @vendor_for_async_callback
    end

    def create_module(mth, mod_name, file, line)
      aliased_method = :"_non_async_#{mth}"
      source = <<-RUBY
      module #{mod_name}
        def self.included(base)
          base.class_eval do
            alias_method(:#{aliased_method}, :#{mth}) unless respond_to? :#{aliased_method}
            alias_method(:#{aliased_method}=, :#{mth}=) unless respond_to? :#{aliased_method}=
            if method_defined?('#{mth}')
              undef #{mth}
            end

            def #{mth}
              callback = vendor_callback("#{mth}")
              Rails.logger.info "  has async callback for #{mth}: " + (callback ? 'yes' : 'no')
              if callback
                callback.value(self)
              else
                self.#{aliased_method}
              end
            end

            def #{mth}=(value)
              callback = vendor_callback("#{mth}")
              Rails.logger.info "  has async callback for #{mth}=: " + (callback ? 'yes' : 'no')

              callback.set_value(self, value) if callback

              self.#{aliased_method} = value
              self.#{aliased_method}
            end

            def current_#{mth}
              callback = vendor_callback("#{mth}")
              if callback
                callback.current(self)
              else
                #{mth}
              end
            end

            def current_#{mth}=(value)
              callback = vendor_callback("#{mth}")
              if callback
                callback.set_current(self, value)
              else
                #{mth}= value
              end
            end

            def #{mth}_changed?
              #{mth}.to_s.size > 0 && #{mth} != current_#{mth}
            end
          end
        end
      end
      include #{mod_name}
      RUBY
      module_eval source, file, line.to_i
    end
  end

  class AsyncVendorCallback
    def initialize(vendor, beacon, cast, mth, key)
      @vendor = vendor
      @beacon = beacon
      @cast = cast
      @key = key
      @mth = mth
    end

    def beacon(owner)
      owner.instance_exec(&@beacon)
    end

    def current(owner)
      beacon = owner.instance_exec(&@beacon)
      cast(
          if beacon.config.has_own_key?(@key)
            beacon.config.send(@key)
          else
            owner.send(:"_non_async_#{@mth}")
          end
      )
    end

    def set_current(owner, value)
      beacon = owner.instance_exec(&@beacon)
      beacon.config[@key] = value
    end

    def value(owner)
      beacon = owner.instance_exec(&@beacon)
      if beacon.config.has_old_value? @mth.to_s
        cast beacon.config.old_value_for @mth.to_s
      else
        current(owner)
      end
    end

    def set_value(owner, value)
      beacon = owner.instance_exec(&@beacon)
      beacon.config[@key] = value
    end

    def changed?
      value.to_s != current.to_s
    end

    def cast(val)
      @cast.to_s.split('.').reduce(val) { |value, mth| value.send(mth) }
    end
  end
end
