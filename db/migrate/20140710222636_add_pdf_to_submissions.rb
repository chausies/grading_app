class AddPdfToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :pdf, :string
  end
end
