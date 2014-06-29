class AddSidToEnrollmentModel < ActiveRecord::Migration
  def change
  	add_column :enrollments, :SID, :string
    add_index :enrollments, :SID
  end
end
