class WorkspacesController < ApplicationController
  before_action :set_workspace, only: :show

  def index
    @workspaces = Current.user.workspaces.order(:name)
  end

  def new
    @workspace = Current.user.workspaces.new
  end

  def create
    @workspace = Current.user.workspaces.new(workspace_params)

    if @workspace.save
      redirect_to notes_path(workspace_id: @workspace.id)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    redirect_to notes_path(workspace_id: @workspace.id)
  end

private
  def set_workspace
    @workspace = Current.user.workspaces.find(params[:id])
  end

  def workspace_params
    params.expect(workspace: [:name])
  end
end
