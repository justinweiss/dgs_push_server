require 'csv'

class Game < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  belongs_to :player

  def self.parse_from_csv(csv_string)
    games = []
    CSV.parse(csv_string, quote_char: "'") do |row|
      games << Game.from_csv_row(row) if (row[0] == 'G')
    end
    games
  end

  def self.from_csv_row(row)
    Game.new({
      dgs_game_id: row[1],
      opponent_name: row[2],
      created_at: row[4],
      updated_at: row[4],
    })
  end

  def self.merge_games(old_games, new_games)
    # TODO: abandon early where the newest existing game is newer / same as the newest new game
    old_game_index = old_games.index_by(&:dgs_game_id)
    new_game_index = new_games.index_by(&:dgs_game_id)

    added_games = new_games.select {|new_game| new_game.added?(old_game_index) }
    removed_games = old_games.select {|old_game| old_game.removed?(new_game_index) }
    existing_games = old_games.select {|old_game| old_game.included?(new_game_index) }

    [added_games, removed_games, existing_games]
  end

  def newer?(other_game)
    updated_at > other_game.updated_at
  end

  # A game has been added if it doesn't exist in the old index, or if
  # it is newer than the existing game in the old index.
  def added?(old_game_index)
    old_game = old_game_index[dgs_game_id]
    !old_game || self.newer?(old_game)
  end

  # A game is removed if it doesn't exist in the new index.
  def removed?(new_game_index)
    !new_game_index[dgs_game_id]
  end

  # A game is in both indexes if it's in the new game index and it's
  # the same or newer than the new game.
  def included?(new_game_index)
    new_game = new_game_index[dgs_game_id]
    new_game && !new_game.newer?(self)
  end
end
