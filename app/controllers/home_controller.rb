class HomeController < ApplicationController
  allow_unauthenticated_access only: %i[ index ]
  def index
    return redirect_to workspaces_path if authenticated?

    @notes = Current.user ? Current.user.notes : Note.none
  end
end
