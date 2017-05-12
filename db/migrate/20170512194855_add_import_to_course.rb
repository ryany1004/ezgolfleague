class AddImportToCourse < ActiveRecord::Migration
  def change
    change_table :courses do |t|
      t.string :import_tag
      t.string :website_url
    end
  end
end
