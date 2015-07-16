###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module KontaktIo
  module Resource
    class Base
      include Virtus.model

      #
      # Maps CamelCase attributes names to snake_case and calls Virtus constructor.
      #
      def initialize(*params)
        params[0] = params[0].each_with_object({}){|(k,v), hash|
          hash[k.to_s.underscore] = v
        } if params[0].is_a?(Hash)
        super
      end

    end
  end
end
