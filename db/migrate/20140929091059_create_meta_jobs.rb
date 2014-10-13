class CreateMetaJobs < ActiveRecord::Migration
  def change
    create_table :meta_jobs do |t|
      t.string :identifier
      t.integer :job_id

      t.timestamps
    end
		add_index :meta_jobs, :identifier
		add_index :meta_jobs, :job_id
  end
end
