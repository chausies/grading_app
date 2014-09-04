class AddSubpartIdToGradingsAndGrades < ActiveRecord::Migration
  def change
		add_column :gradings, :subpart_id, :integer
		add_column :grades,   :subpart_id, :integer
  end
end
