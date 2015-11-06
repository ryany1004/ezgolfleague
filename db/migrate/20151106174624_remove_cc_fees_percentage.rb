class RemoveCcFeesPercentage < ActiveRecord::Migration
  def change
    remove_column :leagues, :credit_card_fee_percentage
  end
end
