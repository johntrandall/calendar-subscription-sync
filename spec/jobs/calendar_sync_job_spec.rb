require 'rails_helper'

describe CalendarSyncJob do

  it 'works' do
    user = User.create!
    url = 'webcal://www.webcal.fi/cal.php?id=41&format=ics&ph=1&ecl=1&pa=1&es=1&du=mi&wrn=1&wp=2&wf=26&color=%23666666&cntr=us&lang=en&rid=wc'
    calendar_sync_definition = CalendarSyncDefinition.create!(user: user, subscribed_calendar_url: url)
    described_class.new.perform(calendar_sync_definition.id)
  end

  describe 'integration' do
    before do
      Rails.logger = Logger.new(STDOUT); Rails.logger.level = :INFO
    end

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

    context 'with random holidays calendar' do
      let(:ics_url) { "webcal://www.webcal.fi/cal.php?id=41&format=ics&ph=1&ecl=1&pa=1&es=1&du=mi&wrn=1&wp=2&wf=26&color=%23666666&cntr=us&lang=en&rid=wc" }
      it 'creates event on google cal' do
        calendar_sync_definition = CalendarSyncDefinition.create!(user: user, subscribed_calendar_url: ics_url)
        described_class.new.perform(calendar_sync_definition.id, limit: 3)
      end

      it 'updates event on google cal' do
        calendar_sync_definition = CalendarSyncDefinition.create!(user: user, subscribed_calendar_url: ics_url)
        described_class.new.perform(calendar_sync_definition.id, limit: 3)
        described_class.new.perform(calendar_sync_definition.id, limit: 3)
        #TODO(JR) Success is to see the logger 'update' rather than 'new'
      end

      xit 'deletes a disappeared event on google cal' do

      end

    end

    context 'with TeamSnap calendar' do
      let(:ics_url) { "http://ical-cdn.teamsnap.com/team_schedule/241e42f9-da74-4e0f-b228-cfdb43f89b8e.ics" }
      it 'creates event on google cal' do
        calendar_sync_definition = CalendarSyncDefinition.create!(user: user, subscribed_calendar_url: ics_url)
        described_class.new.perform(calendar_sync_definition.id, limit: 3)
      end

      it 'updates event on google cal' do
        calendar_sync_definition = CalendarSyncDefinition.create!(user: user, subscribed_calendar_url: ics_url)
        puts 'FIRST RUN'
        described_class.new.perform(calendar_sync_definition.id, limit: 3)

        puts 'SECOND RUN'
        described_class.new.perform(calendar_sync_definition.id, limit: 3)
        #TODO(JR) Success is to see the logger 'update' rather than 'new'
      end

      xit 'deletes a disappeared event on google cal' do

      end
    end
  end
end
