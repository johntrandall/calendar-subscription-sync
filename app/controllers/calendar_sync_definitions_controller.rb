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

  def create
    url = params[:calendar_sync_definition][:subscribed_calendar_url]
    current_user.calendar_sync_definitions.create!(subscribed_calendar_url: url)

    flash[:notice] = "sync definition created!"
    redirect_to calendar_sync_definitions_path
  end
end
