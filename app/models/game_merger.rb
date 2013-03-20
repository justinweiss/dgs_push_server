# Merges two lists of DGS games and reports on the changes between the
# lists.
class GameMerger
  attr_reader :added_games, :removed_games, :existing_games

  def initialize(old_games, new_games)
    # TODO: abandon early where the newest existing game is newer / same as the newest new game
    merge!(old_games, new_games)
  end

  # The game list, after merging with the new game list
  def current_games
    existing_games + added_games
  end

  private

  # A game has been added if it doesn't exist in the old index, or if
  # it is newer than the existing game in the old index.
  def added?(new_game, old_game_index)
    old_game = old_game_index[new_game.dgs_game_id]
    !old_game || new_game.newer?(old_game)
  end

  # A game is removed if it doesn't exist in the new index.
  def removed?(old_game, new_game_index)
    !new_game_index[old_game.dgs_game_id]
  end

  # A game is in both indexes if it's in the new game index and it's
  # the same or newer than the new game.
  def included?(old_game, new_game_index)
    new_game = new_game_index[old_game.dgs_game_id]
    new_game && !new_game.newer?(old_game)
  end

  def merge!(old_games, new_games)
    old_game_index = old_games.index_by(&:dgs_game_id)
    new_game_index = new_games.index_by(&:dgs_game_id)

    @added_games = new_games.select {|new_game| added?(new_game, old_game_index) }
    @removed_games = old_games.select {|old_game| removed?(old_game, new_game_index) }
    @existing_games = old_games.select {|old_game| included?(old_game, new_game_index) }
  end

end
