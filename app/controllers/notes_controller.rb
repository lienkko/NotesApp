class NotesController < ApplicationController
  before_action :set_note, only: %i[ show edit update destroy ]

  def index
    @workspaces = Current.user.accessible_workspaces.order(:name)
    @workspace = @workspaces.find_by(id: params[:workspace_id])
    return redirect_to workspaces_path unless @workspace

    @notes = @workspace.notes.includes(:category)

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
    @workspace = Current.user.accessible_workspaces.find_by(id: params[:workspace_id])
    return redirect_to workspaces_path unless @workspace

    @note = @workspace.notes.new(user: Current.user)
  end

  def create
    @workspace = Current.user.accessible_workspaces.find_by(id: params[:workspace_id])
    return redirect_to workspaces_path unless @workspace

    @note = @workspace.notes.new(
      note_params.except(:tag_names, :new_category_name).merge(user: Current.user)
    )

    if save_note
      @note.assign_tag_names
      broadcast_workspace_refresh
      broadcast_note_refresh
      redirect_to @note
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @note.assign_attributes(
      note_params.except(:tag_names, :new_category_name)
    )

    if save_note
      @note.assign_tag_names
      broadcast_workspace_refresh
      broadcast_note_refresh
      redirect_to @note
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    workspace_id = @note.workspace_id
    note_id = @note.id
    @note.destroy
    broadcast_workspace_refresh(workspace_id)
    broadcast_note_redirect(note_id, workspace_id)
    redirect_to notes_path(workspace_id: workspace_id), notice: "Заметка удалена"
  end

private
  def set_note
    @note = Note.where(workspace: Current.user.accessible_workspaces).find(params[:id])
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

  def broadcast_workspace_refresh(workspace_id = @note.workspace_id)
    Turbo::StreamsChannel.broadcast_refresh_to("workspace_#{workspace_id}")
  end

  def broadcast_note_refresh
    Turbo::StreamsChannel.broadcast_refresh_to("note_#{@note.id}")
  end

  def broadcast_note_redirect(note_id, workspace_id)
    Turbo::StreamsChannel.broadcast_action_to(
      "note_#{note_id}",
      action: :redirect,
      attributes: { url: notes_path(workspace_id: workspace_id) },
      render: false
    )
  end
end
