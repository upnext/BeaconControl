###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

require_relative '../lib/app_status'

BeaconControl::Application.routes.draw do
  mount(
    AppStatus::Rack.new do |config|
      config.add_class AppStatus::DatabaseCheckRequest, name: :database_ok?
      config.add_class AppStatus::MigrationsCheckRequest, name: :migrations_ok?
    end => '/status'
  )

  require 'sidekiq/web'
  authenticate :admin do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :applications, except: [:show] do
    member do
      post :set_apns_sandbox_cert
      post :set_apns_production_cert
    end

    resources :activities, except: [:new] do
      collection do
        get '/:event_type/new', to: 'activities#new', as: :new
        delete :destroy
      end
    end
    resources :rpush_apps_application, only: [:destroy]
    resource :applications_zones
    resource :applications_beacons

    resources :extensions, only: [:index], id: /[A-Z0-9\.]+/i, path: 'add_ons' do
      member do
        put :activate
        put :deactivate
      end
    end
  end

  devise_for :admins, controllers: {
    registrations: 'admin/registrations',
    confirmations: 'admin/confirmations',
    passwords: 'admin/passwords',
    sessions: 'admin/sessions',
  }
  as :admin do
    put 'admins/confirmation' => 'admin/confirmations#update', as: 'update_admin_confirmation'
    unless AppConfig.registerable
      get 'admins/edit' => 'admin/registrations#edit', as: :edit_admin_registration
      put 'admins/update' => 'admin/registrations#update', as: :admin_registration
    end
  end

  resource :profile, only: [:update]

  resources :admins, except: [:show], path: 'users' do
    collection do
      delete :batch_delete
    end
  end if AppConfig.user_management

  resource :static_pages, path: '', only: [] do
    member do
      get :introduction, path: 'walkthrough/intro'
      get :add_beacon, path: 'walkthrough/add_beacon'
      get :link_beacon, path: 'walkthrough/link_beacon'
      get :create_action, path: 'walkthrough/create_action'
      get :customize_features, path: 'walkthrough/customize_features'
      get :glossary, path: 'walkthrough/glossary'
    end
  end

  resources :beacons, except: [:show] do
    collection do
      patch :batch_update
      delete :batch_delete
      get :search
    end
  end
  resources :beacons_search, only: [:index]
  resources :zones

  resource :map

  resources :extension_assignments, only: [:show, :edit, :update]

  resources :extensions_marketplace, only: [:index, :edit, :update], id: /[A-Z0-9\.]+/i, path: 'add_ons' do
    member do
      put :activate
      put :deactivate
    end
  end

  scope 'api/v1', scope: 'api' do
    use_doorkeeper do
      skip_controllers :applications, :authorized_applications
    end
  end

  namespace :api do
    namespace :v1 do
      resources :configurations, only: [:index]
      resources :events, only: [:create]
    end
  end

  scope 's2s_api/v1', scope: 's2s_api' do
    use_doorkeeper do
      skip_controllers :applications, :authorized_applications
    end
  end

  namespace :s2s_api do
    namespace :v1 do
      resource :registrations, only: [:create], path: 'admins'
      resources :vendors, only: :index

      resource :password, only: [:create, :update]

      resources :applications, only: [:index, :create, :update, :destroy] do
        resources :application_settings, only: [:index] do
          collection do
            put :update
          end
        end

        resources :extensions, only: [], id: /[A-Z0-9\.]+/i do
          member do
            put :activate
            put :deactivate
          end
        end

        resources :activities, only: [:index, :create, :update, :destroy]
      end

      resources :zone_colors, only: [:index]
      resources :zones, only: [:index, :create, :update, :destroy] do
        member do
          get :beacons
        end
      end

      resources :beacons, only: [:index, :create, :update, :destroy] do
        collection do
          delete :index, action: :batch_destroy
        end

        member do
          get :info

          match 'config' => 'beacon_configs#update', via: :put
          match 'config' => 'beacon_configs#show', via: :get
          match 'beacon_updated' => 'beacon_configs#confirm', via: :put
          put :sync
        end
      end

      scope :admin do
        resources :admins, path: 'users', only: [:index, :create, :update, :destroy] if AppConfig.user_management
      end
    end
  end

  namespace :mobile do
    resources :coupons, only: [:show] do
      get :barcode
    end
  end

  if AppConfig.landing_page_url
    unauthenticated do
      as :admin do
        root to: redirect(AppConfig.landing_page_url), as: :unauthenticated_root
      end
    end
  end

  root to: 'dashboard#index'
end
