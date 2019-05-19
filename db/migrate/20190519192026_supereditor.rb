class Supereditor < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :supereditor, :boolean, default: false

    User.update_all(supereditor: false)

    User.find(922).update(supereditor: true)
  end
end
