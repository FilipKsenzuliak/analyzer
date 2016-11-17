class CreateParsers < ActiveRecord::Migration
  def change
    create_table :parsers do |t|
      t.string :name
      t.string :expression
      t.boolean :blacklist
      t.string :source_group
      t.string :string

      t.timestamps null: false
    end
  end
end
