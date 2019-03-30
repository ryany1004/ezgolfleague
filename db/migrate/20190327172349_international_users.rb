class InternationalUsers < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :country, :string

  	User.all.each do |c|
  		c.country = "United States"
  		c.save
  	end
  end
end
