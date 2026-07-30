class Board
  SIZE = 9

  WINNING_LINES = [
    [ 0, 1, 2 ], [ 3, 4, 5 ], [ 6, 7, 8 ],
    [ 0, 3, 6 ], [ 1, 4, 7 ], [ 2, 5, 8 ],
    [ 0, 4, 8 ], [ 2, 4, 6 ]
  ].freeze

  def initialize(moves)
    @moves = moves
  end

  def cells
    @cells ||= Array.new(SIZE).tap do |cells|
      moves.each { |move| cells[move.position] = move.player }
    end
  end

  def next_turn
    moves.count.even? ? "X" : "O"
  end

  def winner
    WINNING_LINES.each do |line|
      marks = line.map { |position| cells[position] }
      return marks.first if marks.uniq.size == 1 && marks.first.present?
    end

    nil
  end

  def draw?
    winner.nil? && cells.none?(&:nil?)
  end

  def over?
    winner.present? || draw?
  end

  private

  attr_reader :moves
end
