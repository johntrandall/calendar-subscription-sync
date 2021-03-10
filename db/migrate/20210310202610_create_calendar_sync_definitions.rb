class CreateCalendarSyncDefinitions < ActiveRecord::Migration[6.1]
  def change
    create_table :calendar_sync_definitions do |t|
      t.string :subscribed_calendar_url
      t.references :user

      t.timestamps
    end
  end
end
