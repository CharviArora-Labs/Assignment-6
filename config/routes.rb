Rails.application.routes.draw do
  resources :appointments do
    member do
      patch :cancel
    end
  end
end
