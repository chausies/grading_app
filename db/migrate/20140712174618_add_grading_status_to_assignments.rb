class AddGradingStatusToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :began_grading, :boolean, default: false
    add_column :assignments, :finished_grading, :boolean, default: false
  end
end
