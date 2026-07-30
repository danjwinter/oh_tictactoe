class Game < ApplicationRecord
  before_create { self.uuid ||= SecureRandom.uuid }

  # Games are looked up by UUID (not the auto-incrementing id) so a game's
  # URL doesn't reveal how many games have been played, or let one be
  # guessed from another's id.
  def to_param
    uuid
  end
end
