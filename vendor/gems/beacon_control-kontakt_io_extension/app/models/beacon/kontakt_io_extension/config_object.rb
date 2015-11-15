require 'beacon' unless defined? Beacon

class Beacon
  module KontaktIoExtension
    module ConfigObject
      extend ActiveSupport::Concern

      included do
        unless method_defined?(:kontakt_extended)
          attr_reader :kontakt_extended
          alias_method :_non_kontakt_io_extension_compatibility, :extension_compatibility

          # Overrides Beacon::ConfigObject#extension_compatibility
          # Prepare data loaded from KontaktIo API.
          def extension_compatibility(hash)
            hash = _non_kontakt_io_extension_compatibility(hash)
            hash[:transmission_power] = hash[:tx_power] if hash.key?(:tx_power)
            hash[:signal_interval] = hash[:interval] if hash.key?(:interval)
            hash[:proximity] = hash[:proximity] if hash.key?(:proximity)
            hash.delete(:was_imported)
            hash
          end

          def self.create_default_methods(mth)
            class_eval <<-RUBY, __FILE__, __LINE__+1
              def #{mth}(*);super;end unless method_defined?(:#{mth})
              def #{mth}=(*);super;end unless method_defined?(:#{mth}=)
              def current_#{mth}(*);super;end unless method_defined?(:current_#{mth})
              def current_#{mth}=(*);super;end unless method_defined?(:current_#{mth}=)
            RUBY
          end

          def has_old_value?(key)
            return false unless config.present?
            return false unless config.has_own_key?(key)
            config[key].present?
          end

          def old_value_for(key)
            config[key]
          end

          def self.kontakt_io_attribute(name, kontakt_key, cast=:to_i)
            current = :"current_#{name}"
            non = :"_non_kontakt_io_#{name}"
            return if method_defined?(current)
            create_default_methods(name) unless method_defined?(name)
            alias_method non, name if method_defined?(non)
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{current}
                value = self['#{kontakt_key}']
                value = #{non} unless value.present?
                value.#{cast}
              end
              def #{name}
                if has_old_value? '#{kontakt_key}'
                  old_value_for('#{kontakt_key}').#{cast}
                else
                  #{current}
                end
              rescue
                #{current}
              end
              def #{name}_changed?
                #{current}.to_s.size > 0 && #{name} != #{current}
              end
            RUBY
          end

          kontakt_io_attribute(:transmission_power, :tx_power)
          kontakt_io_attribute(:signal_interval, :interval)
        end
      end
    end
  end
end
