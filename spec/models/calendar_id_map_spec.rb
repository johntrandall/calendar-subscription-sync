# == Schema Information
#
# Table name: calendar_id_maps
#
#  id                          :bigint           not null, primary key
#  google_cal_updated_at       :datetime
#  ics_uid                     :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  calendar_sync_definition_id :bigint
#  google_cal_id               :string
#
# Indexes
#
#  index_calendar_id_maps_on_calendar_sync_definition_id  (calendar_sync_definition_id)
#
require 'rails_helper'

RSpec.describe CalendarIdMap, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
