Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :importer, only: [:index, :create] do
      collection do
        get :template
      end
    end
  end
end
