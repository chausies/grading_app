class AddAttributesToAssignments < ActiveRecord::Migration
  def change
  	add_column :assignments, :max_points, :decimal
  	add_column :assignments, :min_points, :decimal
  end
end
