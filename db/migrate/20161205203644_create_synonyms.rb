class CreateSynonyms < ActiveRecord::Migration
  def change
    create_table :synonyms do |t|
      t.string :text

      t.timestamps null: false
    end
  end
end
