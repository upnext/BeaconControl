###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module RequestHelper

  # Aliases request methods with json_ prefix for using HTTP verbs with HTTP_ACCEPT header set to application/json.
  %w(get post put head delete).each do |method_name|
    define_method :"json_#{method_name}"  do |path, args = {}, headers = {}|
      send(method_name.to_sym, path, args, headers.merge('HTTP_ACCEPT' => 'application/json') )
    end
  end

  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end
end
