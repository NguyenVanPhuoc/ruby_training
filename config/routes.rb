Rails.application.routes.draw do
  resources :users
  resources :teams do
    member do
      get :manage_members
      post :add_member
      delete :remove_member
    end
  end

  get    'login',  to: 'auth#login'
  post   'post_login',  to: 'auth#handle_login', as: :post_login
  delete 'logout', to: 'auth#logout', as: :logout

  get  '/passwords/new',  to: 'passwords#new',    as: :new_password
  post '/passwords',      to: 'passwords#create', as: :passwords
  get  '/passwords/edit', to: 'passwords#edit',   as: :edit_password
  patch '/passwords',     to: 'passwords#update'

  root 'users#index'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letters"
  end

end