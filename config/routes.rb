DgsPushServer::Application.routes.draw do
  resources :players, :only => [] do
    resources :apns_devices, :only => [:create, :update, :destroy], :path => "devices"
  end
end
