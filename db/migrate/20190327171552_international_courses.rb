class InternationalCourses < ActiveRecord::Migration[5.2]
  def change
  	add_column :courses, :country, :string

  	Course.all.each do |c|
  		c.country = "United States"
  		c.save
  	end
  end
end
