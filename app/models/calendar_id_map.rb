# == Schema Information
#
# Table name: calendar_id_maps
#
#  id                          :bigint           not null, primary key
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
class CalendarIdMap < ApplicationRecord
  belongs_to :calendar_sync_definition
end
