class CalendarSyncJob < ApplicationJob

  def perform(calendar_sync_definition_id)
    Rails.logger { "#{self.class.name}.perform on #{calendar_sync_definition_id}) started" }
    calendar_sync_definition = CalendarSyncDefinition.find(calendar_sync_definition_id)
    source_url = calendar_sync_definition.subscribed_calendar_url.gsub('webcal://', 'http://')
    user = calendar_sync_definition.user


    # get ICS data
    require 'net/http'
    uri = URI(source_url)
    ics_string = Net::HTTP.get(uri)

    # cal_file = File.open(ics_string) # Open a file or pass a string to the parser

    cals = Icalendar::Calendar.parse(ics_string) # Parser returns an array of calendars because a single file can have multiple calendars.
    cal = cals.first

    # Now you can access the cal object in just the same way I created it
    events = cal.events

    # finding_by_uid
    # event = cal.events.first
    # event_uid = event.uid
    # event_again = cal.find_event(uid)


    puts "start date-time: #{event.dtstart}"
    puts "start date-time timezone: #{event.dtstart.ical_params['tzid']}"
    puts "summary: #{event.summary}"

    # @google_calendar_service = Google::Apis::CalendarV3::CalendarService.new
  end
end
