class CreateCalendarIdMaps < ActiveRecord::Migration[6.1]
  def change
    create_table :calendar_id_maps do |t|
      t.references :calendar_sync_definition
      t.string :google_cal_id
      t.string :ics_uid

      t.timestamps
    end
  end
end
