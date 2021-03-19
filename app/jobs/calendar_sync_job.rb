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

  def perform(calendar_sync_definition_id, limit_for_spec: nil)
    Rails.logger.info { "#{self.class.name}.perform on #{calendar_sync_definition_id} START" }

    calendar_sync_definition = CalendarSyncDefinition.find(calendar_sync_definition_id)
    user = calendar_sync_definition.user

    ics_string = fetch_ics_string(calendar_sync_definition)
    ics_events = parse_ics_string_to_events(ics_string)

    google_calendar_gateway = GoogleCalendarPushAndSyncEventService.new(user)

    sync_ics_feed_to_google(calendar_sync_definition, google_calendar_gateway, ics_events, limit_for_spec)

    Rails.logger.info { "#{self.class.name}.perform on #{calendar_sync_definition_id} END" }
  end

  private

  def sync_ics_feed_to_google(calendar_sync_definition, google_calendar_gateway, ics_events, limit_for_spec)
    ics_events.each do |ics_source_event|
      @count ||= 0; @count += 1; break if (limit_for_spec && @count > limit_for_spec)
      Rails.logger.info { "processing event #{ics_source_event.uid}" }

      google_calendar_gateway.sync_ics_event_to_google(ics_source_event, calendar_sync_definition)
    end
  end

  def parse_ics_string_to_events(ics_string)
    cals = Icalendar::Calendar.parse(ics_string) # Parser returns an array of calendars because a single file can have multiple calendars.
    cal = cals.first
    events_from_ics_string_value = events = cal.events
    ics_events = events_from_ics_string_value
  end

  def fetch_ics_string(calendar_sync_definition)
    source_url = calendar_sync_definition.subscribed_calendar_url.gsub('webcal://', 'http://')
    uri = URI(source_url)
    ics_string_from_url_value = get_ics_data_value = ics_string = Net::HTTP.get(uri)
    # cal_file = File.open(ics_string) # Open a file or pass a string to the parser
    ics_string = ics_string_from_url_value
  end
end
