class CreateMoves < ActiveRecord::Migration[8.1]
  def change
    create_table :moves do |t|
      t.references :game, null: false, foreign_key: true
      t.string :player, null: false
      t.integer :position, null: false

      t.timestamps

      t.index [ :game_id, :position ], unique: true
    end
  end
end
