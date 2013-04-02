DgsPushServer::Application.routes.draw do
  scope({format: true, constraints: {format: :json}}) do
    resources :players, only: [] do
      resources :apns_devices, only: [:create, :update, :destroy], path: "devices"
      resource :session, only: [:create]
      resources :games, only: [] do
        post :play, on: :member
      end
    end
    put 'players/:player_id/games.:format' => 'games#update_all'
  end

  get '/test/fail'
  get '/test/succeed'
end
