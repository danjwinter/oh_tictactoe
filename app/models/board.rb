class Board
  SIZE = 9

  def initialize(moves)
    @moves = moves
  end

  def cells
    Array.new(SIZE).tap do |cells|
      moves.each { |move| cells[move.position] = move.player }
    end
  end

  def next_turn
    moves.count.even? ? "X" : "O"
  end

  private

  attr_reader :moves
end
