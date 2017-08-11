class AddImportToCourse < ActiveRecord::Migration[4.2]
  def change
    change_table :courses do |t|
      t.string :import_tag
      t.string :website_url
    end
  end
end
