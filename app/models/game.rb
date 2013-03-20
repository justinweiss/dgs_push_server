class Game < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  belongs_to :player

  def newer?(other_game)
    updated_at > other_game.updated_at
  end
end
