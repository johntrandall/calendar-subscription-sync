class CalendarSyncJob < ApplicationJob

  def self.queue_all
    Rails.logger.info { "#{self.name}.queue_all" }
    CalendarSyncDefinition.all.find_each do |csd|
      # begin
      CalendarSyncJob.new.perform(csd.id)
      # rescue
      #   next
      # end
    end
  end

  def perform(calendar_sync_definition_id, limit: nil)
    Rails.logger.info { "#{self.class.name}.perform on #{calendar_sync_definition_id} start" }

    calendar_sync_definition = CalendarSyncDefinition.find(calendar_sync_definition_id)
    source_url = calendar_sync_definition.subscribed_calendar_url.gsub('webcal://', 'http://')
    user = calendar_sync_definition.user

    # get ICS data
    require 'net/http'
    uri = URI(source_url)
    ics_string = Net::HTTP.get(uri)
    # cal_file = File.open(ics_string) # Open a file or pass a string to the parser
    #
    cals = Icalendar::Calendar.parse(ics_string) # Parser returns an array of calendars because a single file can have multiple calendars.
    cal = cals.first
    events = cal.events

    @count = 0
    events.each do |ics_source_event|
      @count += 1; break if (limit && @count > limit)
      Rails.logger.info { "processing event #{ics_source_event.uid}" }

      refresh_calendar_service(user)

      g_event = Google::Apis::CalendarV3::Event.new(google_cal_data_from_ics_data(ics_source_event))
      if mapping = calendar_sync_definition.calendar_id_maps.find_by(ics_uid: ics_source_event.uid.to_s)
        Rails.logger.info { 'updating on Google' }
        response = @calendar_service.update_event('primary', mapping.google_cal_id, g_event)
      else
        Rails.logger.info { 'creating new on Google' }
        response = @calendar_service.insert_event('primary', g_event)
      end
      calendar_sync_definition.calendar_id_maps.first_or_create(ics_uid: ics_source_event.uid, google_cal_id: response.id).update!(google_cal_updated_at: Time.current)

      #TODO destroy if needed. Might not need it because the status "cancelled" might do it for us.
    end
    Rails.logger.info { "#{self.class.name}.perform on #{calendar_sync_definition_id} end" }
  end

  def google_cal_data_from_ics_data(source_event)
    {
      summary: source_event.summary,
      description: source_event.description,
      status: event_status(source_event),
      :start => { :date_time => source_event.dtstart.to_datetime },
      :end => { :date_time => source_event.dtend.to_datetime }
    }
  end

  private

  def refresh_calendar_service(user)
    require "google/apis/calendar_v3"
    require 'google/api_client/client_secrets.rb'
    secrets = Google::APIClient::ClientSecrets.new(
      { "web" =>
          { "access_token" => user.token,
            "refresh_token" => user.refresh_token,
            "client_id" => Rails.application.credentials.google.fetch(:client_id),
            "client_secret" => Rails.application.credentials.google.fetch(:client_secret)
          }
      }
    )
    calendar_service_refreshed(secrets)
  end

  def calendar_service_refreshed(secrets)
    @calendar_service = Google::Apis::CalendarV3::CalendarService.new

    @calendar_service.authorization = secrets.to_authorization

    # TODO(JR) need to get scope and token for refresh to work on heroku?
    # TODO(JR) do we need to refresh here each time?
    # https://github.com/googleapis/google-api-ruby-client/issues/862
    @calendar_service.authorization.refresh!
    @calendar_service
  end

  def event_status(source_event)
    if source_event.status&.downcase&.in?(["confirmed", "tentative", "cancelled"])
      source_event.status.downcase
    else
      'confirmed'
    end

  end
end
