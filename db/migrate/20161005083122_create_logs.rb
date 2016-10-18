class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.string :text
      t.string :label

      t.timestamps null: false
    end
  end
end
