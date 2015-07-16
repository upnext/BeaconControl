###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module S2sApi
  module V1
    class BaseSerializer < ActiveModel::Serializer

      private

      def with_attributes(attributes, condition)
        {}.tap do |hash|
          if object.send(condition)
            attributes.each_with_object(hash){|k,h|
              h[k] = object.send(k)
            }
          end
        end
      end
    end
  end
end
