Spree::Core::Engine.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    resources :shipments do
      resources :rates, only: [:index], module: :shipwire
    end
  end

  namespace :shipwire_webhooks do
    resources :stock, only: :create

    # match all HEAD from shipwire for webhook subscription
    match '*path' => '/spree/shipwire_webhook#subscribe', via: :head
  end
end
