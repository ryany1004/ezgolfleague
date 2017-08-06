class ForceContainerSite < ActiveRecord::Migration[4.2]
  def change
    change_table :leagues do |t|
      t.string :required_container_frame_url
    end
  end
end
