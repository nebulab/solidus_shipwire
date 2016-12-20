Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  namespace :shipwire_webhooks do
    resources :stock, only: :create

    # match all HEAD from shipwire for webhook subscription
    match '*path' => '/spree/shipwire_webhook#subscribe', via: :head
  end
end
