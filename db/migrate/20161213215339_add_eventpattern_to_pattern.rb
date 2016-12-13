class AddEventpatternToPattern < ActiveRecord::Migration
  def change
    add_column :patterns, :event_pattern, :string
  end
end
