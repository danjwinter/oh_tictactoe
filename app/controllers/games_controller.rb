class GamesController < ApplicationController
  def new
  end

  def create
    game = Game.create!
    redirect_to game
  end

  def show
    game = find_game!
    render locals: { game: game, board: game.board }
  end
end
