###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

BeaconControl::AnalyticsExtension::Engine.routes.draw do
  resources :applications, only: [] do
    resource  :analytics
  end

  resources :events, only: [] do
    get :dwell_times, on: :collection
    get :action_counts, on: :collection
    get :unique_users, on: :collection
  end
end
