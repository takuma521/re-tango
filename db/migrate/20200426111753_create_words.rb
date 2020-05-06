class CreateWords < ActiveRecord::Migration[6.0]
  def change
    create_table :words do |t|
      t.references :book, null: false, foreign_key: true
      t.integer :correct_answer_count, null: false, default: 0
      t.integer :question_count, null: false, default: 0
      t.string :name, null: false, default: ''
      t.string :translation, null: false, default: ''

      t.timestamps
    end
  end
end
