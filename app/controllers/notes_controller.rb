class NotesController < ApplicationController
  before_action :set_note, only: %i[ show destroy ]

  def index
    @notes = Note.includes(:category)

    @notes = if params[:category_id] == "none"
      @notes.where(category_id: nil)
    elsif params[:category_id].present?
      @notes.where(category_id: params[:category_id])
    else
      @notes
    end

    @notes = case params[:sort]
    when "oldest"
      @notes.order(created_at: :asc)
    when "title"
      @notes.order(title: :asc)
    else
      @notes.order(created_at: :desc)
    end
  end

  def show
  end

  def new
    @note = Note.new
  end

  def create
    @note = Note.new(
      note_params.except(:tag_names, :new_category_name).merge(user: Current.user)
    )

    if save_note
      @note.assign_tag_names
      redirect_to @note
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    redirect_to notes_path, notice: "Заметка удалена"
  end

private
  def set_note
    @note = Note.find(params[:id])
  end
  def note_params
    params.expect(note: [
      :title,
      :body,
      :category_id,
      :new_category_name,
      :tag_names
    ])
  end

  def save_note
    Note.transaction do
      @note.category = category_from_params
      @note.tag_names = note_params[:tag_names]
      @note.save!
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def category_from_params
    category_id = note_params[:category_id]
    return if category_id.blank?
    return Category.find(category_id) unless category_id == "new"

    name = note_params[:new_category_name].to_s.strip
    Category.find_or_create_by!(name: name) unless name.blank?
  end
end
