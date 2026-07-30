class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  # Games are looked up by uuid, not id — see Game#to_param. param_name
  # differs because :moves is nested under :game_id, while :games' own
  # show action uses :id.
  def find_game!(param_name = :id)
    Game.find_by!(uuid: params[param_name])
  end
end
