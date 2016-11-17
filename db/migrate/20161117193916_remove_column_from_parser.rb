class RemoveColumnFromParser < ActiveRecord::Migration
  def change
  	remove_column :parsers, :string
  end
end
