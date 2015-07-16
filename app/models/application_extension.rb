###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class ApplicationExtension < ActiveRecord::Base
  belongs_to :application

  serialize :configuration, Hash

  attr_accessor :username, :password
end
