class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :tag
      t.string :clasification
      t.string :description
      t.boolean :original

      t.timestamps null: false
    end
  end
end
