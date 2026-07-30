class AddUuidToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :uuid, :string
    add_index :games, :uuid, unique: true
  end
end
