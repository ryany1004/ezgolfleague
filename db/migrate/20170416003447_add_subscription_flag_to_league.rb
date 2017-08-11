class AddSubscriptionFlagToLeague < ActiveRecord::Migration[4.2]
  def change
    change_table :leagues do |t|
      t.boolean :exempt_from_subscription, default: false
    end

    League.all.each do |l|
      l.exempt_from_subscription = true
      l.save
    end
  end
end
