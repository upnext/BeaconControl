###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Admin
  # Factory for Admin model.
  class Factory
    def initialize(params)
      self.admin = Admin.new(params)
    end

    # @final
    # @return [Admin]
    def create
      save_admin! if admin.valid?
      admin
    end

    def create!
      save_admin!
      admin
    end

    private

    # @final
    # @return [TrueClass|FalseClass]
    def create_test_application!
      Application::Factory.new(admin, name: 'App', test: true).create
    end

    # @final
    # @return [TrueClass|FalseClass]
    def save_admin!
      build_account

      Admin.transaction do
        save_admin
        create_test_application if create_test_app?
      end
    end

    attr_accessor :admin

    def build_account
      admin.build_account(name: admin.email, brand: Brand.first)
    end

    def save_admin
      admin.save
    end

    def create_test_application
      create_test_application!
    end

    def create_test_app?
      AppConfig.create_test_app_on_new_account
    end
  end
end
