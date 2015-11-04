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

          def self.kontakt_io_attribute(name, kontakt_key, cast=:to_i)
            current = :"current_#{name}"
            non = :"_non_kontakt_io_#{name}"
            return if method_defined?(current)
            create_default_methods(name) unless method_defined?(name)
            alias_method non, name if method_defined?(non)
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{current}
                _non_kontakt_io_#{name}.#{cast}
              end
              def #{name}
                if config[:#{kontakt_key}].nil?
                  #{current}
                else
                  config.#{kontakt_key}.#{cast}
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
          kontakt_io_attribute(:major, :major)
          kontakt_io_attribute(:minor, :minor)
          kontakt_io_attribute(:proximity, :proximity, :'to_s.upcase')
          kontakt_io_attribute(:instance, :instance_id, :'to_s')
          kontakt_io_attribute(:namespace, :namespace, :'to_s')
          kontakt_io_attribute(:url, :url, :'to_s')
        end
      end
    end
  end
end
