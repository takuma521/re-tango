class CreateWords < ActiveRecord::Migration[6.0]
  def change
    create_table :words do |t|
      t.references :book, null: false, foreign_key: true
      t.string :name
      t.string :translation

      t.timestamps
    end
  end
end
