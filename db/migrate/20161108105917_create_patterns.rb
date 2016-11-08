class CreatePatterns < ActiveRecord::Migration
  def change
    create_table :patterns do |t|
      t.string :text
      t.string :source

      t.timestamps null: false
    end
  end
end
