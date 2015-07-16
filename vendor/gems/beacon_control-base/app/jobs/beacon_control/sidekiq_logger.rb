###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module SidekiqLogger

    #
    # Returns Sidekiq logger to keep all workers/jobs -related log entries in one file.
    #
    def logger
      Sidekiq.logger
    end
  end
end