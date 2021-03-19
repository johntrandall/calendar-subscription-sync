class CalendarSyncDefinitionsController < ApplicationController

  def index
    @calendar_sync_definitions = current_user.calendar_sync_definitions
    if @calendar_sync_definitions.empty?
      redirect_to new_calendar_sync_definition_path
    end
  end

  def new
    @calendar_sync_definition = CalendarSyncDefinition.new(user: current_user)
  end

  def edit
    @calendar_sync_definition = current_user.calendar_sync_definitions.find(params[:id])
  end

  def create
    url = params[:calendar_sync_definition][:subscribed_calendar_url]
    current_user.calendar_sync_definitions.create!(subscribed_calendar_url: url)

    flash[:notice] = "sync definition created!"
    redirect_to calendar_sync_definitions_path
  end

  def update
    @calendar_sync_definition = current_user.calendar_sync_definitions.find(params[:id])

    @calendar_sync_definition.update!(calendar_sync_definition_params)
    flash[:notice] = "sync definition updated!"
    redirect_to calendar_sync_definitions_path
  end

  def perform_sync
    calendar_sync_definition = current_user.calendar_sync_definitions.find(params[:id])
    CalendarSyncJob.perform_later(calendar_sync_definition.id)

    flash[:notice] = "running sync"
    redirect_to calendar_sync_definitions_path
  end

  def calendar_sync_definition_params
    params.require(:calendar_sync_definition).permit(
      :subscribed_calendar_url,
      :description_prepend_string,
    )
  end
end
