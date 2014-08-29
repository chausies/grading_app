class CreateSubparts < ActiveRecord::Migration
  def change
    create_table :subparts do |t|
			t.string :name
			t.string :index
			t.references :parent, polymorphic: true
			t.decimal :max_points
			t.decimal :min_points
			t.timestamps
    end
		add_index :subparts, :parent_id
  end
end
