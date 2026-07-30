require "rails_helper"

RSpec.describe "Games", type: :request do
  describe "POST /games" do
    it "creates a game and shows its empty board" do
      expect {
        post games_path
      }.to change(Game, :count).by(1)

      follow_redirect!

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("X to move")
    end
  end

  describe "GET /games/:id" do
    it "renders the game's current (empty) board" do
      game = Game.create!

      get game_path(game)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("X to move")
    end
  end
end
