Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  namespace :shipwire_webhooks do
    resources :stock, only: :create
  end
end
