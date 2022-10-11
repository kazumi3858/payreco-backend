Rails.application.routes.draw do
  namespace 'api' do
    namespace 'v1' do
      get 'user', to: 'users#show'
      patch 'user', to: 'users#update'
      delete 'user', to: 'users#destroy'
      resources :accounts, only: [:destroy]
      resources :companies, :works, only: [:index, :create, :update, :destroy]
      resources :exchange_rates, only: [:index, :create]
    end
  end
end
