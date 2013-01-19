class ApnsDevicesController < ApplicationController

  respond_to :json
  before_filter :load_app
  before_filter :load_player
  before_filter :load_device_by_token, only: :create
  before_filter :load_device_to_update, only: [:update, :destroy]
  before_filter :verify_app_scope

  def create
    @device.player = @player
    @device.rapns_app = @app
    @device.save!
    respond_with @player, @device
  end

  def update
    @device.player = @player
    @device.rapns_app = @app
    @device.update_attributes(device_params)

    # Always update the device's timestamps, so we can see if they're
    # still being used.
    @device.touch if @device.previous_changes.empty?

    # Since we could have changed the id here, we can't rely on the
    # default respond_with, since we need to return the updated object
    # back to the user.
    respond_with @player, @device do |format|
      format.json { render :json => @device }
    end
  end

  def destroy
    @device.destroy
    respond_with @player, @device
  end

  private

  def load_player
    @player = Player.where(dgs_user_id: params[:player_id]).first_or_initialize
  end

  def load_device_by_token
    @device = ApnsDevice.where(device_token: device_params[:device_token]).first_or_initialize
  end

  def load_device_to_update
    @device = ApnsDevice.find_by_device_token(device_params[:device_token]) ||
      ApnsDevice.scoped_by_id(params[:id]).first_or_initialize
  end

  def load_app
    @app = Rapns::Apns::App.find_by_name(request.headers["X_BUNDLE_IDENTIFIER"])
    render_404 unless @app
  end

  def verify_app_scope
    raise ActiveRecord::RecordNotFound if @device.rapns_app && @device.rapns_app != @app
  end

  def device_params
    params.fetch(:device) { {} }.slice(:device_token)
  end
end
