class AddOverridePriceForLeague < ActiveRecord::Migration[5.2]
  def change
  	add_column :leagues, :override_golfer_price, :decimal
  end
end
