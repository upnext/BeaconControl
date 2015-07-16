###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

#
# Extendable module, adds uuid-type attribute to class with own validation rules and value manipulation
# in +before_validation+.
#
module UuidField
  extend self

  #
  # Injects all functionality to desired class.
  #
  # ==== Parameters
  #
  # * +field_name+     - String, name of field under which uuid attribute will be registered
  # * +options+        - Hash, extra optopns to configure attribute. Valid keys:
  #   * +:validations+ - Hash, extra validations to be applied to uuid field
  #
  def uuid_field(field_name, options = {})
    self.class_eval do
      class_attribute :uuid_field

      self.uuid_field = field_name

      validations = options.fetch(:validations, {})

      validates uuid_field, { format: UuidFormat::REGEX, allow_blank: true }.merge(validations)

      before_validation :convert_uuid_field

      define_method :convert_uuid_field do
        send(uuid_field).to_s.upcase!
      end
      private :convert_uuid_field
    end
  end
end
