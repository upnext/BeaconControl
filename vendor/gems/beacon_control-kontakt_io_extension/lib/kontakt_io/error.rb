###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module KontaktIo

  #
  # Wraps Kontakt.io API response codes into Ruby +StandardError+ subclasses.
  # http://docs.kontakt.io/rest-api/guide/#status-codes
  #
  class Error < StandardError
    def self.classify(code)
      case code
      when 400 then Error::Invalid.new('Request contains invalid values or is in invalid format')
      when 401 then Error::Unauthorized.new('Unauthorized access. Most likely Api-Key hasn’t been sent')
      when 403 then Error::Forbidden.new('Forbidden. Tried to access a resource that isn’t theirs')
      when 404 then Error::NotFound.new('Resource not found')
      when 409 then Error::Conflict.new('Conflict. Will return information as to the cause')
      when 415 then Error::UnsupportedType.new('Version or Mediatype not found')
      when 422 then Error::UnprocessableEntity.new('Parameters validation error')
      else Error.new(code)
      end
    end
  end

  class Error::Invalid < Error; end             # 400
  class Error::Unauthorized < Error; end        # 401
  class Error::Forbidden < Error; end           # 403
  class Error::NotFound < Error; end            # 404
  class Error::Conflict < Error; end            # 409
  class Error::UnsupportedType < Error; end     # 415
  class Error::UnprocessableEntity < Error; end # 422
end
