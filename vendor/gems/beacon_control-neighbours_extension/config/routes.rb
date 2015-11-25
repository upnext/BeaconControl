BeaconControl::NeighboursExtension::Engine.routes.draw do
  resources :applications, only: [] do
    resource  :neighbours
    resources :zones, only: [] do
      resources :zone_neighbours, only: [:create, :destroy, :sync] do
        collection do
          get :sync
        end
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resource :zone_neighbours, only: [:create, :destroy, :show]
    end
  end

  namespace :s2s_api do
    namespace :v1 do
      resources :zone_neighbours, only: [:create, :destroy, :show]
    end
  end
end
