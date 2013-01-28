class TestController < ApplicationController
  def fail
    raise "Way to go, you broke it!"
  end
end
