require 'rails_helper'

describe GoogleCalendarPushAndSyncEventService do
  describe "integration specs", vcr: { record: :once,
                                       match_requests_on: [:method, :uri, :body] } do

    let(:ics_events) { CalendarSyncJob.new.send(:parse_ics_string_to_events, ics_string) }
    let(:user) do
      User.create!(
        email: "john.randall.dev.spec@gmail.com",
        provider: 'google_oauth2',
        uid: "116577227563317117676",
        token: "ya29.a0AfH6SMDcHh8X1ixefRnmofI-tjfp-vyLw86uzZpYSnC-D3ZBGgiAY1xEaDHU_dVh2B2bP0SJAOuKfYZJaKzUNeAX8K_KWtevVyKBPV1MQrdI-Kc5jxZpbAQDxZJN47bR-0mC1Jackh3wXjLJT2jemhPDSfwg",
        refresh_token: "1//0dmUiPDHcAVdNCgYIARAAGA0SNwF-L9IrbmZ5KvrXIL5vZwuhriHLvWb-zh3fXBvgRiUdl2I-r72dE1il4cT56CxtpN0jC-8oKcY",
        expires: "t",
        expires_at: "1615581216",
        google_auth: { "uid" => "116577227563317117676",
                       "info" =>
                         { "name" => "John Randall",
                           "email" => "john.randall.dev.spec@gmail.com",
                           "image" =>
                             "https://lh4.googleusercontent.com/-sdI6T8zynSo/AAAAAAAAAAI/AAAAAAAAAAA/AMZuuclyndgNI_yurBqzKDXEmNyiYB7weg/s96-c/photo.jpg",
                           "last_name" => "Randall",
                           "first_name" => "John",
                           "email_verified" => true,
                           "unverified_email" => "john.randall.dev.spec@gmail.com" },
                       "extra" =>
                         { "id_info" =>
                             { "aud" =>
                                 "431521155175-jk5tkoac3r0u7f1pkuc9actmacagt4pt.apps.googleusercontent.com",
                               "azp" =>
                                 "431521155175-jk5tkoac3r0u7f1pkuc9actmacagt4pt.apps.googleusercontent.com",
                               "exp" => 1615581217,
                               "iat" => 1615577617,
                               "iss" => "https://accounts.google.com",
                               "sub" => "116577227563317117676",
                               "name" => "John Randall",
                               "email" => "john.randall.dev.spec@gmail.com",
                               "locale" => "en",
                               "at_hash" => "pgC816AWEDV4VthMI9TX6Q",
                               "picture" =>
                                 "https://lh4.googleusercontent.com/-sdI6T8zynSo/AAAAAAAAAAI/AAAAAAAAAAA/AMZuuclyndgNI_yurBqzKDXEmNyiYB7weg/s96-c/photo.jpg",
                               "given_name" => "John",
                               "family_name" => "Randall",
                               "email_verified" => true },
                           "id_token" =>
                             "eyJhbGciOiJSUzI1NiIsImtpZCI6Ijg0NjJhNzFkYTRmNmQ2MTFmYzBmZWNmMGZjNGJhOWMzN2Q2NWU2Y2QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI0MzE1MjExNTUxNzUtams1dGtvYWMzcjB1N2YxcGt1YzlhY3RtYWNhZ3Q0cHQuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI0MzE1MjExNTUxNzUtams1dGtvYWMzcjB1N2YxcGt1YzlhY3RtYWNhZ3Q0cHQuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTY1NzcyMjc1NjMzMTcxMTc2NzYiLCJlbWFpbCI6ImpvaG4ucmFuZGFsbC5kZXYuc3BlY0BnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXRfaGFzaCI6InBnQzgxNkFXRURWNFZ0aE1JOVRYNlEiLCJuYW1lIjoiSm9obiBSYW5kYWxsIiwicGljdHVyZSI6Imh0dHBzOi8vbGg0Lmdvb2dsZXVzZXJjb250ZW50LmNvbS8tc2RJNlQ4enluU28vQUFBQUFBQUFBQUkvQUFBQUFBQUFBQUEvQU1adXVjbHluZGdOSV95dXJCcXpLRFhFbU55aVlCN3dlZy9zOTYtYy9waG90by5qcGciLCJnaXZlbl9uYW1lIjoiSm9obiIsImZhbWlseV9uYW1lIjoiUmFuZGFsbCIsImxvY2FsZSI6ImVuIiwiaWF0IjoxNjE1NTc3NjE3LCJleHAiOjE2MTU1ODEyMTd9.BeigsczKTEZzSaRpD1bV4QoT2zCjkyCCfwFNmd_1cdXLyK7hqQCbCuALfaytTMq_iTL3-Xzc5HELERvUfhCvxmkI66caZbgenzcMmT72AZ3LVMMyj9_7g7_Rbh9oOMRJVHMRLoCEzLj39DLJnD2jJiuC5LAiPbClZ0nhGD70E6qlKFE2Zn6nhu-CChoN6z_BgZkpMKYM3X3d4joHsywHey0Hlu9N3Oml3Q_oJEgavxWqOWvLHeXdjyRz1RfEeRZH8JX5MxRPEphzMJVtve74w2V_Pg7o1vXkC4XHqM9j0MBz2E-wsN0BKK_iE1eTeFtzKK3mu-gCVpScToROxfi4bQ",
                           "raw_info" =>
                             { "sub" => "116577227563317117676",
                               "name" => "John Randall",
                               "email" => "john.randall.dev.spec@gmail.com",
                               "locale" => "en",
                               "picture" =>
                                 "https://lh4.googleusercontent.com/-sdI6T8zynSo/AAAAAAAAAAI/AAAAAAAAAAA/AMZuuclyndgNI_yurBqzKDXEmNyiYB7weg/s96-c/photo.jpg",
                               "given_name" => "John",
                               "family_name" => "Randall",
                               "email_verified" => true } },
                       "provider" => "google_oauth2",
                       "credentials" =>
                         { "token" =>
                             "ya29.a0AfH6SMDcHh8X1ixefRnmofI-tjfp-vyLw86uzZpYSnC-D3ZBGgiAY1xEaDHU_dVh2B2bP0SJAOuKfYZJaKzUNeAX8K_KWtevVyKBPV1MQrdI-Kc5jxZpbAQDxZJN47bR-0mC1Jackh3wXjLJT2jemhPDSfwg",
                           "expires" => true,
                           "expires_at" => 1615581216,
                           "refresh_token" =>
                             "1//0dmUiPDHcAVdNCgYIARAAGA0SNwF-L9IrbmZ5KvrXIL5vZwuhriHLvWb-zh3fXBvgRiUdl2I-r72dE1il4cT56CxtpN0jC-8oKcY" } })
    end
    let(:ics_string) {
      <<-ICS_STRING
BEGIN:VCALENDAR
PRODID;X-RICAL-TZSOURCE=TZINFO:-//com.denhaven2/NONSGML ri_cal gem//EN
CALSCALE:GREGORIAN
VERSION:2.0
METHOD:PUBLISH
X-WR-CALNAME:2013 Boys Montclair United Blue
X-WR-CALDESC:The event schedule for the 2013 Boys Montclair United Blue S
 occer team
X-WR-TIMEZONE:America/New_York
X-PUBLISHED-TTL:PT1H
X-TS-TIMESTAMP:2021-03-16 10:29:43
BEGIN:VTIMEZONE
TZID;X-RICAL-TZSOURCE=TZINFO:America/New_York
BEGIN:DAYLIGHT
DTSTART:20200308T020000
RDATE:20200308T020000
RDATE:20210314T020000
TZOFFSETFROM:-0500
TZOFFSETTO:-0400
TZNAME:EDT
END:DAYLIGHT
BEGIN:STANDARD
DTSTART:20201101T020000
RDATE:20201101T020000
TZOFFSETFROM:-0400
TZOFFSETTO:-0500
TZNAME:EST
END:STANDARD
END:VTIMEZONE

BEGIN:VEVENT
DTEND;TZID=America/New_York;VALUE=DATE-TIME:20200916T161500
DTSTART;TZID=America/New_York;VALUE=DATE-TIME:20200916T161500
DTSTAMP;VALUE=DATE-TIME:20200915T221438Z
LAST-MODIFIED;VALUE=DATE-TIME:20200915T221438Z
UID:7004706-229270390
DESCRIPTION:Location: Brookdale Stadium\n   (Arrival Time:  4:15 PM (East
ern Time (US & Canada)))
SUMMARY:2013 Boys Montclair United Blue - U8 Boys PRACTICE
LOCATION:East Circuit Drive\, Bloomfield\, NJ 07003
SEQUENCE:0
END:VEVENT

      ICS_STRING
    }

    describe "#sync_ics_event_to_google" do
      it "when mapping does not exist, it persists a mapping" do
        calendar_sync_definition = CalendarSyncDefinition.create!(user: user)
        expect { described_class.new(user).sync_ics_event_to_google(ics_events.first, calendar_sync_definition) }
          .to change { CalendarIdMap.count }.by(1)
      end
      it "when mapping does exist, and data hasn't changed, it does nothing" do
        calendar_sync_definition = CalendarSyncDefinition.create!(user: user)
        expect { described_class.new(user).sync_ics_event_to_google(ics_events.first, calendar_sync_definition) }
          .to change { CalendarIdMap.count }.by(1)
        pre_existing_mapping = CalendarIdMap.last

        expect { described_class.new(user).sync_ics_event_to_google(ics_events.first, calendar_sync_definition); pre_existing_mapping.reload }
          .to change { CalendarIdMap.count }.by(0)
                .and not_change { pre_existing_mapping.attributes }

      end
      it "when mapping does exist, it updates the mapping" do
        calendar_sync_definition = CalendarSyncDefinition.create!(user: user)
        expect { described_class.new(user).sync_ics_event_to_google(ics_events.first, calendar_sync_definition) }
          .to change { CalendarIdMap.count }.by(1)
        pre_existing_mapping = CalendarIdMap.last

        ics_events.first.description = "i have changed!"
        ics_events.first.last_modified = ics_events.first.last_modified + 1.day

        expect { described_class.new(user).sync_ics_event_to_google(ics_events.first, calendar_sync_definition); pre_existing_mapping.reload }
          .to change { CalendarIdMap.count }.by(0)
                                            .and change { pre_existing_mapping.updated_at }
      end
    end

    describe "#fetch_event_from_google after #sync_ics_event_to_google" do

      let(:calendar_sync_definition) { CalendarSyncDefinition.create!(user: user) }
      let(:first_ics_event) { ics_events.first }
      let(:remote_google_cal_id_after_push) do
        expect { described_class.new(user).sync_ics_event_to_google(first_ics_event, calendar_sync_definition) }.to change { CalendarIdMap.count }.by(1)
        new_calendar_id_map = CalendarIdMap.last
        new_calendar_id_map.google_cal_id
      end

      it 'returns a Google::Apis::CalendarV3::Event object' do
        fetched_event = described_class.new(user).fetch_google_event_from_google(remote_google_cal_id_after_push)
        expect(fetched_event).to be_a Google::Apis::CalendarV3::Event
      end

      it 'correctly posts data' do
        fetched_event = described_class.new(user).fetch_google_event_from_google(remote_google_cal_id_after_push)
        expect(fetched_event.location.to_s).to eq(first_ics_event.location.to_s)
      end

      describe 'appointment vs all-day (DateTime vs Date)' do

        it 'posts as a DateTime' do
          fetched_event = described_class.new(user).fetch_google_event_from_google(remote_google_cal_id_after_push)
          expect(fetched_event.start.date_time.class).to eq(DateTime)
          expect(fetched_event.start.date.class).to eq(NilClass)
        end

        context 'from an all-day event' do
          let(:ics_string) {
            <<-ICS_STRING
BEGIN:VCALENDAR
PRODID;X-RICAL-TZSOURCE=TZINFO:-//com.denhaven2/NONSGML ri_cal gem//EN
CALSCALE:GREGORIAN
VERSION:2.0
METHOD:PUBLISH
X-WR-CALNAME:2013 Boys Montclair United Blue
X-WR-CALDESC:The event schedule for the 2013 Boys Montclair United Blue S
 occer team
X-WR-TIMEZONE:America/New_York
X-PUBLISHED-TTL:PT1H
X-TS-TIMESTAMP:2021-03-16 10:29:43
BEGIN:VTIMEZONE
TZID;X-RICAL-TZSOURCE=TZINFO:America/New_York
BEGIN:DAYLIGHT
DTSTART:20200308T020000
RDATE:20200308T020000
RDATE:20210314T020000
TZOFFSETFROM:-0500
TZOFFSETTO:-0400
TZNAME:EDT
END:DAYLIGHT
BEGIN:STANDARD
DTSTART:20201101T020000
RDATE:20201101T020000
TZOFFSETFROM:-0400
TZOFFSETTO:-0500
TZNAME:EST
END:STANDARD
END:VTIMEZONE

BEGIN:VEVENT
DTEND;VALUE=DATE:20200927
DTSTART;VALUE=DATE:20200926
DTSTAMP;VALUE=DATE-TIME:20200926T020029Z
LAST-MODIFIED;VALUE=DATE-TIME:20200926T020029Z
UID:7004706-229270555
DESCRIPTION:Location: See notes below\n Hi -teams below - please confirm 
 your availability if you have not already\;\n\n1. Crossen team Away at N
 orthern Valley 2pm (Directions  below)\nCrossen\, Johnson\, McDonnell\, 
 Shine\, Van Dzura\, Deborou\n2. Moore team Away at Ajax 3:15pm (Directio
 ns below)\;\nAbeytunge\, Baker\, Meskill\, Moore\, Soni\, Srikanth\, Ked
 dell\n3. Keddell team GAME OFF!!- Home at 4:30 vs Americans\n\nMinister 
 TBD\n\n\nSunday game will be set up for a different Crossen team on sepa
 rate schedule.\n\nNorthern Valley - Harrington Park\, Highland Field - U
 pper Small \nTappan Road\,  Harrington Park\, NJ 07640\nTake Central Ave
  past the High School heading toward Norwood. At the light\, make a righ
 t onto Tappan Road. Once you enter Harrington Park\, Highland Field is t
 he large group of fields on your left side. The Upper Small sided field 
 is to the left of the basketball courts.\n\n\nAjax - Midland Park High S
 chool\, 250 Prospect Street\n Midland Park\, NJ 07432\nTake Route 208 to
  Goffle Road/Midland Park/Ridgewood exit. Stay on Goffle Road north unti
 l end (2nd light) and make a left onto Godwin Avenue. At the 1st light\,
  make a right onto Prospect Street. In slightly less than one mile\, ent
 rance to school is on right. Park in spots in front of school or field\,
  which located at the south end of the property adjacent to the school. 
  (Arrival Time: 11:30 PM (Eastern Time (US & Canada))) 
SUMMARY:2013 Boys Montclair United Blue - U8 Boys League Games
LOCATION:Varied - See notes
SEQUENCE:0
END:VEVENT
            ICS_STRING
          }
          it 'posts as a Date' do
            fetched_event = described_class.new(user).fetch_google_event_from_google(remote_google_cal_id_after_push)
            expect(fetched_event.start.date_time.class).to eq(NilClass)
            expect(fetched_event.start.date.class).to eq(Date)
          end
        end
      end
    end
  end
end

