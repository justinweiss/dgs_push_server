class Game < ActiveRecord::Base
  belongs_to :player
  attr_accessible :dgs_game_id, :opponent_name
end
