class Game < ApplicationRecord
  has_many :moves, -> { order(:id) }

  before_create { self.uuid ||= SecureRandom.uuid }

  # Games are looked up by UUID (not the auto-incrementing id) so a game's
  # URL doesn't reveal how many games have been played, or let one be
  # guessed from another's id.
  def to_param
    uuid
  end

  def board
    # Always reload: a Game object can outlive a single move being created
    # against it (e.g. several Moves validated/created against the same
    # in-memory Game), and the moves association would otherwise cache a
    # stale, pre-move result.
    Board.new(moves.reload)
  end
end
