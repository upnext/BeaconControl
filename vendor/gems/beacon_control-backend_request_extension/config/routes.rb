###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree.
###

BeaconControl::BackendRequestExtension::Engine.routes.draw do
  resources :applications, only: [] do
    resource :backend_request, only: [:show]
  end

  namespace :api do
    namespace :v1 do
      resource :backend_request, only: [:show]
    end
  end
end
