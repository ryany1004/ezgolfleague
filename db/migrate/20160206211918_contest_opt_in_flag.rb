class ContestOptInFlag < ActiveRecord::Migration
  def change
    add_column :contests, :is_opt_in, :boolean, :default => true
    
    Contest.all.each do |c|
      if c.dues_amount.blank? or c.dues_amount == 0
        c.is_opt_in = false
        c.save
      end
    end
  end
end
