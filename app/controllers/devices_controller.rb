class DevicesController < ApplicationController

  respond_to :json
  before_filter :load_app
  before_filter :load_player
  before_filter :load_device_by_token, only: :create
  before_filter :load_device_to_update, only: [:update, :destroy]
  before_filter :verify_app_scope

  def create
    @device.player = @player
    @device.save!
    respond_with @player, @device, location: nil
  end

  def update
    @device.player = @player
    @device.update_attributes(device_params)

    # Since we could have changed the id here, we can't rely on the
    # default respond_with, since we need to return the updated object
    # back to the user.
    respond_with @player, @device do |format|
      format.json { render :json => @device }
    end
  end

  def destroy
    @device.destroy
    respond_with @player, @device, location: nil
  end

  private

  def load_player
    @player = Player.find_by_dgs_user_id!(params[:player_id])
  end

  def load_device_by_token
    @device = ApnsDevice.find_by_encoded_device_token(device_params[:encoded_device_token]).first_or_initialize(rapns_app: @app)
  end

  def load_device_to_update
    @device = ApnsDevice.find_by_encoded_device_token(device_params[:encoded_device_token]).first ||
      ApnsDevice.where(id: params[:id]).first_or_initialize(rapns_app: @app)
  end

  def load_app
    @app = Rapns::Apns::App.find_by_name!(request.headers["X_BUNDLE_IDENTIFIER"])
  end

  def verify_app_scope
    # We're doing this here because of a particular requirement -- if
    # we *find* the token but it belongs to a different app, that's an
    # error. If we *don't* find the token, we automatically create one
    # under the right app.
    raise ActiveRecord::RecordNotFound if @device.rapns_app && @device.rapns_app != @app
  end

  def device_params
    if params[:device]
      params[:device].permit(:encoded_device_token)
    else
      {}
    end
  end
end
