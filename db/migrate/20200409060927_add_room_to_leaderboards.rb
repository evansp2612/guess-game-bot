class AddRoomToLeaderboards < ActiveRecord::Migration[5.2]
  def change
    add_column :leaderboards, :room, :integer
  end
end
