class GoogleCalendarEventFactory
  attr_accessor :ics_source_event, :calendar_sync_definition

  def initialize(ics_source_event, calendar_sync_definition)
    @ics_source_event = ics_source_event
    @calendar_sync_definition = calendar_sync_definition
  end

  def create_unpersisted_from_ics
    event = Google::Apis::CalendarV3::Event.new({
                                                  summary: ics_source_event.summary,
                                                  description: description,
                                                  status: if ics_source_event.status&.downcase&.in?(["confirmed", "tentative", "cancelled"])
                                                            ics_source_event.status.downcase
                                                          else
                                                            'confirmed'
                                                          end,
                                                  location: ics_source_event.location
                                                }.merge(time_fields))

  end

  def description
    [calendar_sync_definition.description_prepend_string, ics_source_event.description].join("\n\n")
  end

  def time_fields
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
end
