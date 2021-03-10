require 'rails_helper'

describe CalendarSyncJob do

  it 'works' do
    user = User.create!
    url = 'webcal://www.webcal.fi/cal.php?id=41&format=ics&ph=1&ecl=1&pa=1&es=1&du=mi&wrn=1&wp=2&wf=26&color=%23666666&cntr=us&lang=en&rid=wc'
    calendar_sync_definition = CalendarSyncDefinition.create!(user: user, subscribed_calendar_url: url)
    described_class.new.perform(calendar_sync_definition.id)
  end

  describe 'integration' do
    let(:user) do
      User.create!(
        token: "ya29.a0AfH6SMC8XKlX90L8OhU7jhZkXpSujXje5Y__78KHN0Ew3lCBMOxTg0yRPs9Fz1PcjIf6M_8P9H1fS3PW62m8cz3VHyRSJqrJGbnDoEyksXW2b52fCSpKkHgNDS1BeSzAM1VT6_zf_MxIKoRyS2UshfZbzWay",
        expires: 't',
        expires_at: '1615418937',
        refresh_token: "1//0dJblOIgRJ4vBCgYIARAAGA0SNwF-L9IrkTF_RTMEMaGXEhgI85ZhSArRFKFVYJK-NhlJo6lacebocWGE6DogtlFYd-ApuOy_rCs",
        google_auth: { "uid" => "100322579295488785312", "info" => { "name" => "John Randall", "email" => "john.randall.developer@gmail.com", "image" => "https://lh4.googleusercontent.com/-hw3_W0X5TDE/AAAAAAAAAAI/AAAAAAAAAAA/AMZuucmiAcstOgC5R7kO-HhZoMzrLwQ-kw/s96-c/photo.jpg", "last_name" => "Randall", "first_name" => "John", "email_verified" => true, "unverified_email" => "john.randall.developer@gmail.com" }, "extra" => { "id_info" => { "aud" => "431521155175-jk5tkoac3r0u7f1pkuc9actmacagt4pt.apps.googleusercontent.com", "azp" => "431521155175-jk5tkoac3r0u7f1pkuc9actmacagt4pt.apps.googleusercontent.com", "exp" => 1615418938, "iat" => 1615415338, "iss" => "https://accounts.google.com", "sub" => "100322579295488785312", "name" => "John Randall", "email" => "john.randall.developer@gmail.com", "locale" => "en", "at_hash" => "3qYpVbGAzfFc16-K9XtlLg", "picture" => "https://lh4.googleusercontent.com/-hw3_W0X5TDE/AAAAAAAAAAI/AAAAAAAAAAA/AMZuucmiAcstOgC5R7kO-HhZoMzrLwQ-kw/s96-c/photo.jpg", "given_name" => "John", "family_name" => "Randall", "email_verified" => true }, "id_token" => "eyJhbGciOiJSUzI1NiIsImtpZCI6Ijg0NjJhNzFkYTRmNmQ2MTFmYzBmZWNmMGZjNGJhOWMzN2Q2NWU2Y2QiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiI0MzE1MjExNTUxNzUtams1dGtvYWMzcjB1N2YxcGt1YzlhY3RtYWNhZ3Q0cHQuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiI0MzE1MjExNTUxNzUtams1dGtvYWMzcjB1N2YxcGt1YzlhY3RtYWNhZ3Q0cHQuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMDAzMjI1NzkyOTU0ODg3ODUzMTIiLCJlbWFpbCI6ImpvaG4ucmFuZGFsbC5kZXZlbG9wZXJAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF0X2hhc2giOiIzcVlwVmJHQXpmRmMxNi1LOVh0bExnIiwibmFtZSI6IkpvaG4gUmFuZGFsbCIsInBpY3R1cmUiOiJodHRwczovL2xoNC5nb29nbGV1c2VyY29udGVudC5jb20vLWh3M19XMFg1VERFL0FBQUFBQUFBQUFJL0FBQUFBQUFBQUFBL0FNWnV1Y21pQWNzdE9nQzVSN2tPLUhoWm9NenJMd1Eta3cvczk2LWMvcGhvdG8uanBnIiwiZ2l2ZW5fbmFtZSI6IkpvaG4iLCJmYW1pbHlfbmFtZSI6IlJhbmRhbGwiLCJsb2NhbGUiOiJlbiIsImlhdCI6MTYxNTQxNTMzOCwiZXhwIjoxNjE1NDE4OTM4fQ.uEqe7RDzIfJCAlIOqgOJP4jVYnE07dH_h7lbqckRxREj0sdrlaWnhHfdYfKKbI5LXZvUqsm4GBSByAb-R4R9iAk1XOSeFZ8sg1IfuYZD6tglDHGchNnEe2QyejLmKFzX3DBicEb_SzzR9ftcQf7NWxklhelAfOgSYZXaDnZrFBp5uwOjN8ImWc6t-f14h7gnNz0YjZNFQ4eJOkO6LW1hpqP5GeRo26YpwycoHiN5fFume1qG6eP7iU2FcOqhxqDEZjCzQI2s-fl-AOKCj8cx-O2R-XF5zr8F5u7PsHaXsnUhxwMxD3greNe-tkr_13xpatJVts2lriXmHeaKJx-Dgw", "raw_info" => { "sub" => "100322579295488785312", "name" => "John Randall", "email" => "john.randall.developer@gmail.com", "locale" => "en", "picture" => "https://lh4.googleusercontent.com/-hw3_W0X5TDE/AAAAAAAAAAI/AAAAAAAAAAA/AMZuucmiAcstOgC5R7kO-HhZoMzrLwQ-kw/s96-c/photo.jpg", "given_name" => "John", "family_name" => "Randall", "email_verified" => true } }, "provider" => "google_oauth2", "credentials" => { "token" => "ya29.a0AfH6SMC8XKlX90L8OhU7jhZkXpSujXje5Y__78KHN0Ew3lCBMOxTg0yRPs9Fz1PcjIf6M_8P9H1fS3PW62m8cz3VHyRSJqrJGbnDoEyksXW2b52fCSpKkHgNDS1BeSzAM1VT6_zf_MxIKoRyS2UshfZbzWay", "expires" => true, "expires_at" => 1615418937, "refresh_token" => "1//0dJblOIgRJ4vBCgYIARAAGA0SNwF-L9IrkTF_RTMEMaGXEhgI85ZhSArRFKFVYJK-NhlJo6lacebocWGE6DogtlFYd-ApuOy_rCs" } }
      )
    end

    it 'copies event to google cal' do
      url = 'webcal://www.webcal.fi/cal.php?id=41&format=ics&ph=1&ecl=1&pa=1&es=1&du=mi&wrn=1&wp=2&wf=26&color=%23666666&cntr=us&lang=en&rid=wc'
      calendar_sync_definition = CalendarSyncDefinition.create!(user: user, subscribed_calendar_url: url)
      described_class.new.perform(calendar_sync_definition.id)
    end

    xit 'updates event on google cal' do

    end

    xit 'deletes a disappeared event on google cal' do

    end
  end
end
