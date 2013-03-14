class TestController < ApplicationController
  def succeed
    render :text => 'ok'
  end

  def fail
    raise "Way to go, you broke it!"
  end
end
