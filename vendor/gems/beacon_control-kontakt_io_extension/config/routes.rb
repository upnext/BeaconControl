###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

BeaconControl::KontaktIoExtension::Engine.routes.draw do
  scope :kontakt_io do
    resources :extensions_marketplace, only: [:update], id: /[A-Z0-9\.]+/i

    resources :beacons, only: [:index, :create] do
      collection do
        post :import
        post :sync
      end
    end
  end
end
