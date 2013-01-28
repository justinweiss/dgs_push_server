DgsPushServer::Application.routes.draw do
  scope({format: true, constraints: {format: :json}}) do
    resources :players, :only => [] do
      resources :apns_devices, :only => [:create, :update, :destroy], :path => "devices"
      resource :session, :only => [:create]
    end
  end

  match '/test/fail' => 'test#fail'
end
