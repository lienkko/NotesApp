class HomeController < ApplicationController
  allow_unauthenticated_access only: %i[ index ]
  def index
    @notes = Note.all
  end
end
