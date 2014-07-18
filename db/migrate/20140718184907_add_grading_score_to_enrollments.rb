class AddGradingScoreToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :grading_score, :float
  end
end
