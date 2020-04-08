class CreateCurrentRounds < ActiveRecord::Migration[5.2]
  def change
    create_table :current_rounds do |t|
      t.string :question
      t.string :answer
      t.string :name

      t.timestamps
    end
  end
end
