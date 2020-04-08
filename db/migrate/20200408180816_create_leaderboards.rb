class CreateLeaderboards < ActiveRecord::Migration[5.2]
  def change
    create_table :leaderboards do |t|
      t.integer :user_id
      t.string :name
      t.integer :point, default: 0

      t.timestamps
    end
  end
end
