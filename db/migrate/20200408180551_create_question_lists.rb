class CreateQuestionLists < ActiveRecord::Migration[5.2]
  def change
    create_table :question_lists do |t|
      t.string :question
      t.string :answer, array: true
      t.boolean :enabled, default: false

      t.timestamps
    end
  end
end
