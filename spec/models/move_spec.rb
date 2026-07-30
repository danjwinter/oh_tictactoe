require "rails_helper"

RSpec.describe Move, type: :model do
  it "is valid with a game, player, and open position" do
    game = Game.create!
    move = Move.new(game: game, player: "X", position: 0)

    expect(move).to be_valid
  end

  it "rejects a position that's already taken in the same game" do
    game = Game.create!
    Move.create!(game: game, player: "X", position: 4)

    move = Move.new(game: game, player: "O", position: 4)

    expect(move).not_to be_valid
    expect(move.errors[:position]).to be_present
  end

  it "allows the same position across different games" do
    game_a = Game.create!
    game_b = Game.create!
    Move.create!(game: game_a, player: "X", position: 4)

    move = Move.new(game: game_b, player: "X", position: 4)

    expect(move).to be_valid
  end

  it "rejects a move once the game has already been won" do
    game = Game.create!
    Move.create!(game: game, player: "X", position: 0)
    Move.create!(game: game, player: "O", position: 3)
    Move.create!(game: game, player: "X", position: 1)
    Move.create!(game: game, player: "O", position: 4)
    Move.create!(game: game, player: "X", position: 2) # X wins the top row

    move = Move.new(game: game, player: "O", position: 5) # still an open cell

    expect(move).not_to be_valid
    expect(move.errors[:game]).to be_present
  end
end
