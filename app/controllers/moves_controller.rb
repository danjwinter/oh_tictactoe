class MovesController < ApplicationController
  def create
    game = find_game!(:game_id)
    move = Move.new(game: game, player: game.board.next_turn, position: move_params[:position])

    if move.save
      redirect_to game
    else
      render_invalid_move(game, move)
    end
  rescue ActiveRecord::RecordNotUnique
    # Belt-and-suspenders for a genuine race between two near-simultaneous
    # requests for the same cell — the uniqueness validation above catches
    # this in the normal (non-racing) case.
    move.errors.add(:position, "is already taken")
    render_invalid_move(game, move)
  end

  private

  def move_params
    params.require(:move).permit(:position)
  end

  def render_invalid_move(game, move)
    flash.now[:alert] = move.errors.full_messages.to_sentence
    render "games/show", locals: { game: game, board: game.board }, status: :unprocessable_content
  end
end
