class AddEnvironmentFlagToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :beta_server, :boolean, default: false

    User.update_all(beta_server: false)
  end
end
