###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module BeaconControl
  module DwellTimeExtension
    class Worker
      def initialize(event, worker = WorkerJob)
        self.event  = event.attributes
        self.worker = worker
      end

      def publish
        worker.perform_later(event)
      end

      private

      attr_accessor :event, :worker
    end
  end
end
