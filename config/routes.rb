DgsPushServer::Application.routes.draw do
  constraints -> (request) { request.format == :json } do
    resources :players, only: [] do
      resources :devices, only: [:create, :update, :destroy]
      resource :session, only: [:create]
      resources :games, only: [:index] do
        post :move, on: :member
      end
      put 'games.:format', to: 'games#update_all'
    end
    
  end

  get '/test/fail'
  get '/test/succeed'

  get "/licenses.html", to: "pages#licenses", as: 'licenses'

  root to: 'pages#homepage', as: 'homepage'
end
