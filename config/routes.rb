DgsPushServer::Application.routes.draw do
  scope({format: true, constraints: {format: :json}}) do
    resources :players, only: [] do
      resources :devices, only: [:create, :update, :destroy]
      resource :session, only: [:create]
      resources :games, only: [:index] do
        post :move, on: :member
      end
    end
    put 'players/:player_id/games.:format' => 'games#update_all'
  end

  get '/test/fail'
  get '/test/succeed'

  match "/licenses.html", :to => "pages#licenses", :as => 'licenses'

  root :to => 'pages#homepage', :as => 'homepage'
end
