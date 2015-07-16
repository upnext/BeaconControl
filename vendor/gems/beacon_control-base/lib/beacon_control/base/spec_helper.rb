###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

Dir[File.join(File.expand_path("../../../../spec/support/**/*.rb", __FILE__))].each { |f| require f }

RSpec.configure do |config|
  config.include ActiveJob::TestHelper, type: :async
  config.include RequestHelper

  config.after(:each) do
    clear_enqueued_jobs if respond_to?(:clear_enqueued_jobs)
  end
end
