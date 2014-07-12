class AddScoreToGradings < ActiveRecord::Migration
  def change
    add_column :gradings, :score, :decimal
  end
end
