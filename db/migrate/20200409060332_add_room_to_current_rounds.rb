class AddRoomToCurrentRounds < ActiveRecord::Migration[5.2]
  def change
    add_column :current_rounds, :room, :integer
  end
end
