class GoogleCalendarGateway
  def initialize(user)
    @google_calendar_service = google_calendar_service(user)
  end

  def push_event_to_google(ics_source_event, calendar_sync_definition)
    # TODO(JR) UNKNOWN do we need to refresh here each time?
    @google_calendar_service.authorization.refresh!

    google_calendar_event = Google::Apis::CalendarV3::Event.new({
                                                                  summary: ics_source_event.summary,
                                                                  description: ics_source_event.description,
                                                                  status: if ics_source_event.status&.downcase&.in?(["confirmed", "tentative", "cancelled"])
                                                                            ics_source_event.status.downcase
                                                                          else
                                                                            'confirmed'
                                                                          end,
                                                                  :start => { :date_time => ics_source_event.dtstart.to_datetime },
                                                                  :end => { :date_time => ics_source_event.dtend.to_datetime }
                                                                })
    response = if mapping = calendar_sync_definition.calendar_id_maps.find_by(ics_uid: ics_source_event.uid.to_s)
                 Rails.logger.info { 'updating on Google' }
                 @google_calendar_service.update_event('primary', mapping.google_cal_id, google_calendar_event)
               else
                 Rails.logger.info { 'creating new on Google' }
                 @google_calendar_service.insert_event('primary', google_calendar_event)
               end
    calendar_sync_definition.calendar_id_maps.where(ics_uid: ics_source_event.uid.to_s, google_cal_id: response.id)
                            .first_or_create!
                            .update!(google_cal_updated_at: Time.current)
    #TODO(JR) UNKNOWN destroy if needed. Might not need it because the status "cancelled" might do it for us.
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
