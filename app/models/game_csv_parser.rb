class GameCSVParser

  def initialize(csv_string)
    @rows = CSV.parse(csv_string, quote_char: "'")
  end

  def games
    game_rows.map { |row| Game.new(game_attributes(row)) }
  end

  private

  def game_rows
    @rows.select { |row| is_game_row?(row) }
  end

  def game_attributes(row)
    {
      dgs_game_id: row[1],
      opponent_name: row[2],
      created_at: row[4],
      updated_at: row[4],
    }
  end

  def is_game_row?(row)
    row[0] == 'G'
  end
end
