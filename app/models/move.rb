class Move < ApplicationRecord
  belongs_to :game

  validates :player, inclusion: { in: %w[X O] }
  validates :position, inclusion: { in: 0..8 }
  validates :position, uniqueness: { scope: :game_id, message: "is already taken" }
  validate :game_not_already_over

  private

  def game_not_already_over
    return unless game

    errors.add(:game, "is already over") if game.board.over?
  end
end
