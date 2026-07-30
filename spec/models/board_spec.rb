require "rails_helper"

RSpec.describe Board do
  def move(position, player)
    Move.new(position: position, player: player)
  end

  describe "with no moves" do
    subject(:board) { described_class.new([]) }

    it "renders an empty grid" do
      expect(board.cells).to eq(Array.new(9))
    end

    it "has X to move" do
      expect(board.next_turn).to eq("X")
    end
  end

  describe "#next_turn" do
    it "is O after an odd number of moves" do
      board = described_class.new([ move(0, "X") ])

      expect(board.next_turn).to eq("O")
    end

    it "is X after an even number of moves" do
      board = described_class.new([ move(0, "X"), move(1, "O") ])

      expect(board.next_turn).to eq("X")
    end
  end

  describe "#winner" do
    winning_lines = [
      [ 0, 1, 2 ], [ 3, 4, 5 ], [ 6, 7, 8 ],
      [ 0, 3, 6 ], [ 1, 4, 7 ], [ 2, 5, 8 ],
      [ 0, 4, 8 ], [ 2, 4, 6 ]
    ]

    winning_lines.each do |line|
      it "detects a win across #{line}" do
        board = described_class.new(line.map { |position| move(position, "X") })

        expect(board.winner).to eq("X")
      end
    end

    it "returns nil when no one has won yet" do
      board = described_class.new([ move(0, "X"), move(1, "O"), move(3, "X") ])

      expect(board.winner).to be_nil
    end
  end

  describe "#draw?" do
    it "is true when the board is full with no winning line" do
      # X O X
      # X O O
      # O X X
      moves = [
        move(0, "X"), move(1, "O"), move(2, "X"),
        move(3, "X"), move(4, "O"), move(5, "O"),
        move(6, "O"), move(7, "X"), move(8, "X")
      ]

      board = described_class.new(moves)

      expect(board.draw?).to be(true)
      expect(board.winner).to be_nil
    end

    it "is false while the board still has empty cells" do
      board = described_class.new([ move(0, "X") ])

      expect(board.draw?).to be(false)
    end
  end

  describe "#over?" do
    it "is true when there is a winner" do
      board = described_class.new([ move(0, "X"), move(1, "X"), move(2, "X") ])

      expect(board.over?).to be(true)
    end

    it "is true when it's a draw" do
      moves = [
        move(0, "X"), move(1, "O"), move(2, "X"),
        move(3, "X"), move(4, "O"), move(5, "O"),
        move(6, "O"), move(7, "X"), move(8, "X")
      ]

      board = described_class.new(moves)

      expect(board.over?).to be(true)
    end

    it "is false while the game is still in progress" do
      board = described_class.new([ move(0, "X") ])

      expect(board.over?).to be(false)
    end
  end
end
