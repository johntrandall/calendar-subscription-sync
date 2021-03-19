class AddDescriptionPrependStringToCalendarSyncDefinition < ActiveRecord::Migration[6.1]
  def change
    add_column :calendar_sync_definitions,  :description_prepend_string, :string
  end
end
