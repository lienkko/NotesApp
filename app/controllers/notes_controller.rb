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
    @note = Note.new(note_params.except(:tag_names).merge(user: Current.user))
    @note.tag_names = note_params[:tag_names]

    if @note.save
      @note.assign_tag_names
      redirect_to @note
    else
      render :new, status: :unprocessable_entity
    end
  end


private
  def note_params
    params.expect(note: [ :title, :body, :category_id, :tag_names ])
  end
end
