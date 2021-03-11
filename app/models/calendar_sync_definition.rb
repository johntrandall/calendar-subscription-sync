class CalendarSyncDefinition < ApplicationRecord
  belongs_to :user
  has_many :calendar_id_maps
end

# == Schema Information
#
# Table name: calendar_sync_definitions
#
#  id                      :bigint           not null, primary key
#  subscribed_calendar_url :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :bigint
#
# Indexes
#
#  index_calendar_sync_definitions_on_user_id  (user_id)
#
