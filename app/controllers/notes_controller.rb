class NotesController < ApplicationController
  def index
    @notes = Note.all
  end

  def show
  end

  def new
    @note = Note.new
  end

  def create
    @note = Note.new(note_params)
    if @note.save
      redirect_to @note
    else
      render :new, status: :unprocessable_entity
    end
  end


private
  def note_params
    params.expect(note: [ :title, :body, :category_id, :tag ])
  end
end
