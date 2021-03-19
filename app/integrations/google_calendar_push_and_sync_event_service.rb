require 'google/api_client/client_secrets.rb'
require "google/apis/calendar_v3"

class GoogleCalendarPushAndSyncEventService
  def initialize(user)
    @google_calendar_service = google_calendar_service(user)
  end

  def sync_ics_event_to_google(ics_source_event, calendar_sync_definition)
    mapping = calendar_sync_definition.calendar_id_maps.find_or_create_by!(ics_uid: ics_source_event.uid.to_s)
    return calendar_sync_definition if mapping.google_cal_updated_at.present? && ics_source_event.last_modified < mapping.google_cal_updated_at

    @calendar_sync_definition = calendar_sync_definition
    unpersisted_google_event = GoogleCalendarEventFactory.new(ics_source_event, @calendar_sync_definition).create_unpersisted_from_ics

    # TODO(JR) UNKNOWN do we need to refresh here each time?
    @google_calendar_service.authorization.refresh!

    if mapping.google_cal_id
      persisted_google_event = @google_calendar_service.update_event('primary', mapping.google_cal_id, unpersisted_google_event)
      mapping.update!(google_cal_updated_at: ics_source_event.last_modified)
    else
      persisted_google_event = @google_calendar_service.insert_event('primary', unpersisted_google_event)
      mapping.update!(google_cal_id: persisted_google_event.id, google_cal_updated_at: ics_source_event.last_modified)
    end

    #TODO(JR) UNKNOWN destroy if needed. Might not need it because the status "cancelled" might do it for us.

    calendar_sync_definition

  end

  def fetch_google_event_from_google(remote_event_id)
    # TODO(JR) UNKNOWN do we need to refresh here each time?
    @google_calendar_service.authorization.refresh!

    @google_calendar_service.get_event('primary', remote_event_id)
  end

  private

  def google_calendar_service(user)
    @google_calendar_service ||= begin
                                   secrets = Google::APIClient::ClientSecrets.new(
                                     { "web" =>
                                         { "access_token" => user.token,
                                           "refresh_token" => user.refresh_token,
                                           "client_id" => Rails.application.credentials.google.fetch(:client_id),
                                           "client_secret" => Rails.application.credentials.google.fetch(:client_secret)
                                         }
                                     }
                                   )
                                   google_calendar_service = Google::Apis::CalendarV3::CalendarService.new
                                   google_calendar_service.authorization = secrets.to_authorization

                                   google_calendar_service
                                 end
  end
end
