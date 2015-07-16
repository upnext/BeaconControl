###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module S2sApi
  module V1
    class ApplicationSettingSerializer < BaseSerializer
      attributes :id, :extension_name, :type, :key, :value

      def attributes *args
        hash = super
        hash[:errors] = object.errors.messages unless object.valid?
        hash
      end

      def value
        object.file? ? object.value.url : object.value
      end
    end
  end
end
