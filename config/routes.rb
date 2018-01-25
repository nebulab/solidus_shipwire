Spree::Core::Engine.routes.draw do
  # Add your extension routes here

  Spree::Core::Engine.routes.draw do
    namespace :admin do
      resources :orders, except: [:show] do
        member do
          get :shipwire
        end
      end
    end

    namespace :api, defaults: { format: 'json' } do
      resources :shipments do
        resources :rates, only: [:index], module: :shipwire
      end
    end
  end

  namespace :shipwire_webhooks do
    resources :stock, only: :create

    # match all HEAD from shipwire for webhook subscription
    match '*path' => '/spree/shipwire_webhook#subscribe', via: :head
  end
end
