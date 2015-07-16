###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class MobileDevice < ActiveRecord::Base
  include HasCorrelationId

  belongs_to :user
  has_one :application, through: :user

  enum environment: { sandbox: 0, production: 1 }
  enum os: { ios: 0, android: 1, windows_phone: 2 }

  validates :push_token, uniqueness:  { scope: [:user_id, :environment] },
                         allow_blank: true,
                         allow_nil:   false

  validates :os,          inclusion: { in: os.flatten }
  validates :environment, inclusion: { in: environments.flatten }

  def self.with_environment(env)
    if env.is_a? Integer
      where(environment: env)
    else
      where(environment: environments[env])
    end
  end

  def os=(val)
    super
  rescue ArgumentError
    write_attribute(:os, val)
  end

  def environment=(val)
    super
  rescue ArgumentError
    write_attribute(:environment, val)
  end
end
