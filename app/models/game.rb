class Game < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  belongs_to :player
  belongs_to :opponent, foreign_key: 'opponent_name', class_name: 'Player', primary_key: 'handle'

  def newer?(other_game)
    updated_at > other_game.updated_at
  end
end
