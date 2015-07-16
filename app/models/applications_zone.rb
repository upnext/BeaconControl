###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class ApplicationsZone < ActiveRecord::Base
  belongs_to :application
  belongs_to :zone

  before_destroy :check_if_test_app

  private

  def check_if_test_app
    !application.test
  end
end
