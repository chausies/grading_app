class CreatePagesAndJoinToSubparts < ActiveRecord::Migration
  def change
    create_table :pages do |t|
			t.integer :assignment_id
			t.integer :solution_id
			t.integer :submission_id
      t.integer :page_num
			t.string  :page_file
      t.timestamps
    end
		
		create_table :pages_subparts_relationships do |t|
			t.integer :page_id
			t.integer :subpart_id
		end

		add_index :pages, :assignment_id
		add_index :pages, :solution_id
		add_index :pages, :submission_id

		add_index :pages_subparts_relationships, :subpart_id
		add_index :pages_subparts_relationships, :page_id
		add_index :pages_subparts_relationships, [:page_id, :subpart_id]
		add_index :pages_subparts_relationships, [:subpart_id, :page_id]
  end
end
