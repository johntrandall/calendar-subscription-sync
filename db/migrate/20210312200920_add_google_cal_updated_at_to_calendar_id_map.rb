class AddGoogleCalUpdatedAtToCalendarIdMap < ActiveRecord::Migration[6.1]
  def change
    add_column :calendar_id_maps,  :google_cal_updated_at, :datetime
  end
end
