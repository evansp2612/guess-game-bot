class AddColumnsToCurrentRounds < ActiveRecord::Migration[5.2]
  def change
    add_column :current_rounds, :asked, :integer, array: true, default: []
    add_column :current_rounds, :pass, :integer, array: true, default: []
    add_column :current_rounds, :round, :integer, null: false
  end
end
