###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module HasCorrelationId
  def update_correlation_id_from_current_thread
    if Thread.current[:request_correlation_id]
      self.correlation_id = Thread.current[:request_correlation_id]
    end
  end
end
