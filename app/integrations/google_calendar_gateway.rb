require 'google/api_client/client_secrets.rb'
require "google/apis/calendar_v3"

class GoogleCalendarGateway
  def initialize(user)
    @google_calendar_service = google_calendar_service(user)
  end

  def sync_ics_event_to_google(ics_source_event, calendar_sync_definition)

    mapping = calendar_sync_definition.calendar_id_maps.find_or_create_by!(ics_uid: ics_source_event.uid.to_s)
    push_ics_event_to_google(ics_source_event, mapping)

    calendar_sync_definition
    #TODO(JR) UNKNOWN destroy if needed. Might not need it because the status "cancelled" might do it for us.
  end

  def fetch_google_event_from_google(remote_event_id)
    # TODO(JR) UNKNOWN do we need to refresh here each time?
    @google_calendar_service.authorization.refresh!

    @google_calendar_service.get_event('primary', remote_event_id)
  end

  private

  def push_ics_event_to_google(ics_source_event, mapping)
    # TODO(JR) UNKNOWN do we need to refresh here each time?
    @google_calendar_service.authorization.refresh!

    unpersisted_google_event = unpersisted_google_event_from_ics(ics_source_event)
    persisted_google_event = push_google_event_to_google(unpersisted_google_event, mapping)
  end

  def push_google_event_to_google(unpersisted_google_event, mapping)
    if mapping.google_cal_id
      Rails.logger.info { 'updating on Google' }
      persisted_google_event = @google_calendar_service.update_event('primary', mapping.google_cal_id, unpersisted_google_event)
      mapping.update!(google_cal_updated_at: Time.current)
    else
      Rails.logger.info { 'creating new on Google' }
      persisted_google_event = @google_calendar_service.insert_event('primary', unpersisted_google_event)
      mapping.update!(google_cal_id: persisted_google_event.id, google_cal_updated_at: Time.current)
    end
    persisted_google_event
  end

  def unpersisted_google_event_from_ics(ics_source_event)
    event = Google::Apis::CalendarV3::Event.new({
                                                  summary: ics_source_event.summary,
                                                  description: ics_source_event.description,
                                                  status: if ics_source_event.status&.downcase&.in?(["confirmed", "tentative", "cancelled"])
                                                            ics_source_event.status.downcase
                                                          else
                                                            'confirmed'
                                                          end,
                                                  location: ics_source_event.location
                                                }.merge(time_fields(ics_source_event)))
    event
  end

  def time_fields(ics_source_event)
    dtstart_klass = ics_source_event.dtstart.class
    if dtstart_klass == Icalendar::Values::DateTime
      {
        :start => { :date_time => ics_source_event.dtstart.to_datetime },
        :end => { :date_time => ics_source_event.dtend.to_datetime },
      }
    elsif dtstart_klass == Icalendar::Values::Date
      {
        :start => { :date => ics_source_event.dtstart.to_date },
        :end => { :date => ics_source_event.dtend.to_date },
      }
    else
      raise
    end
  end

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
