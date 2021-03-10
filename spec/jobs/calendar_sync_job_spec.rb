require 'rails_helper'

describe CalendarSyncJob do

  it 'works' do
    user = User.create!
    url = 'webcal://www.webcal.fi/cal.php?id=41&format=ics&ph=1&ecl=1&pa=1&es=1&du=mi&wrn=1&wp=2&wf=26&color=%23666666&cntr=us&lang=en&rid=wc'
    calendar_sync_definition = CalendarSyncDefinition.create!(user: user, subscribed_calendar_url: url)
    described_class.new.perform(calendar_sync_definition.id)
  end

  xit 'copies event to google cal' do

  end

  xit 'updates event on google cal' do

  end

  xit 'deletes a disappeared event on google cal' do

  end

end
