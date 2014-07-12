class AddBeganGradingToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :began_grading, :boolean, default: false
  end
end
