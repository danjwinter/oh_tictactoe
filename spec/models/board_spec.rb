require "rails_helper"

RSpec.describe Board do
  describe "with no moves" do
    subject(:board) { described_class.new([]) }

    it "renders an empty grid" do
      expect(board.cells).to eq(Array.new(9))
    end

    it "has X to move" do
      expect(board.next_turn).to eq("X")
    end
  end
end
