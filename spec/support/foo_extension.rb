###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

module FooExtension
  def self.registered_name
    "Foo"
  end

  def self.config
    OpenStruct.new({
      registers: {
        settings: [
          {
            i18n_key: :username,
            key: :username,
            type: :string
          },
          {
            i18n_key: :password,
            key: :password,
            type: :password
          },
          {
            i18n_key: :file,
            key: :file,
            type: :file
          }
        ],
        triggers: [
        ]
      }
    })
  end

  class Worker
    attr_reader :event

    def initialize(event)
      @event = event
    end

    def publish
    end
  end
end
