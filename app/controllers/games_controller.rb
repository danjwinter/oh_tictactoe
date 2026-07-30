class GamesController < ApplicationController
  def new
  end

  def create
    game = Game.create!
    redirect_to game
  end

  def show
    game = Game.find_by!(uuid: params[:id])
    # Hardcoded empty until Move exists (ticket 03) — swap for game.moves.
    board = Board.new([])

    render locals: { game: game, board: board }
  end
end
