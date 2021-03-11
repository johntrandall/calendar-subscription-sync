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
    #
    events.each do |source_event|
      # source_event_copyable_attributes = source_event.to_h.except(:created, :etag, :id, :i_cal_uid)

      # puts "start date-time: #{source_event.dtstart}"
      # puts "start date-time timezone: #{source_event.dtstart.ical_params['tzid']}"
      # puts "summary: #{source_event.summary}"

      # talk to google
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

      @calendar_service = Google::Apis::CalendarV3::CalendarService.new

      @calendar_service.authorization = secrets.to_authorization
      @calendar_service.authorization.refresh!
      main_calendar = @calendar_service.get_calendar(user.email)

      # @calendar_service.insert_event('primary',
      #                                event_object = nil,
      #                                conference_data_version: nil,
      #                                max_attendees: nil,
      #                                send_notifications: nil,
      #                                send_updates: nil,
      #                                supports_attachments: nil,
      #                                fields: nil,
      #                                quota_user: nil,
      #                                user_ip: nil,
      #                                options: nil) {}

      event_obj = Google::Apis::CalendarV3::Event.new(hash_from_ics_source(source_event))
      # puts event_obj.summary

      if mapping = calendar_sync_definition.calendar_id_maps.where(ics_uid: source_event.uid.to_s).first
        response = @calendar_service.patch_event('primary', mapping.google_calendar_id, event_obj)
      else
        response = @calendar_service.insert_event('primary', event_obj)
        calendar_sync_definition.calendar_id_maps.create!(ics_uid: source_event.uid, google_cal_id: response.id)
      end

      puts response

      # main
      # @source_calendar = @calendar_service.get_calendar(@google_calendar_syncronization.source_calendar_id, options: {authorization: @auth_client})
      # raise 'just do one!'
    end

  end

  def hash_from_ics_source(source_event)
    {
      summary: source_event.summary,
      description: source_event.description,
      status: event_status(source_event),
      :start => { :date_time => source_event.dtstart.to_datetime },
      :end => { :date_time => source_event.dtend.to_datetime }
    }
  end

  private

  def event_status(source_event)
    source_event.status.downcase if source_event.status.downcase.in?(["confirmed", "tentative", "cancelled"])
  end
end

# if syncronized_remote_event_pair.needs_initial_sync?
#   push_initial_sync(source_event_copyable_attributes, syncronized_remote_event_pair)
# else
#   push_path_sync(source_event_copyable_attributes, syncronized_remote_event_pair)
# end
#
# syncronized_remote_event_pair.update!(last_synced_at: Time.current)
#
#
#
# def push_path_sync(source_event_copyable_attributes, syncronized_remote_event_pair)
#   @calendar_service.patch_event(@destination_calendar_id,
#                                 syncronized_remote_event_pair.remote_destination_event_id,
#                                 source_event_copyable_attributes,
#                                 options: {authorization: @auth_client})
# end
#
# def push_initial_sync(source_event_copyable_attributes, syncronized_remote_event_pair)
#   destination_event = @calendar_service.insert_event(@destination_calendar_id,
#                                                      source_event_copyable_attributes,
#                                                      options: {authorization: @auth_client})
#   syncronized_remote_event_pair.update!(remote_destination_event_id: destination_event.id)
# end
