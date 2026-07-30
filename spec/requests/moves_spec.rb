require "rails_helper"

RSpec.describe "Moves", type: :request do
  describe "POST /games/:game_id/moves" do
    it "creates a move and shows the updated board" do
      game = Game.create!

      expect {
        post game_moves_path(game), params: { move: { position: 4 } }
      }.to change(Move, :count).by(1)

      expect(response).to redirect_to(game_path(game))
      follow_redirect!

      expect(response.body).to include('class="mark">X</span>')
      expect(response.body).to include("O to move")
    end

    it "rejects a move on an already-occupied cell" do
      game = Game.create!
      Move.create!(game: game, player: "X", position: 4)

      expect {
        post game_moves_path(game), params: { move: { position: 4 } }
      }.not_to change(Move, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("is already taken")
    end

    it "rejects a move once the game is already over" do
      game = Game.create!
      Move.create!(game: game, player: "X", position: 0)
      Move.create!(game: game, player: "O", position: 3)
      Move.create!(game: game, player: "X", position: 1)
      Move.create!(game: game, player: "O", position: 4)
      Move.create!(game: game, player: "X", position: 2) # X wins the top row

      expect {
        post game_moves_path(game), params: { move: { position: 5 } }
      }.not_to change(Move, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("is already over")
    end

    it "shows the winner once a move completes a winning line" do
      game = Game.create!
      Move.create!(game: game, player: "X", position: 0)
      Move.create!(game: game, player: "O", position: 3)
      Move.create!(game: game, player: "X", position: 1)
      Move.create!(game: game, player: "O", position: 4)

      post game_moves_path(game), params: { move: { position: 2 } } # X completes the top row

      follow_redirect!
      expect(response.body).to include("X wins!")
      expect(response.body).to include("New Game")
    end

    it "gracefully handles a genuine race on the same cell" do
      game = Game.create!
      allow_any_instance_of(Move).to receive(:save).and_raise(ActiveRecord::RecordNotUnique)

      expect {
        post game_moves_path(game), params: { move: { position: 0 } }
      }.not_to change(Move, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("is already taken")
    end

    it "shows a draw once a move fills the board with no winner" do
      game = Game.create!
      # X O X
      # X O O
      # O X _
      [
        [ 0, "X" ], [ 1, "O" ], [ 2, "X" ],
        [ 3, "X" ], [ 4, "O" ], [ 5, "O" ],
        [ 6, "O" ], [ 7, "X" ]
      ].each { |position, player| Move.create!(game: game, player: player, position: position) }

      post game_moves_path(game), params: { move: { position: 8 } }

      follow_redirect!
      expect(response.body).to include("Draw!")
    end
  end
end
