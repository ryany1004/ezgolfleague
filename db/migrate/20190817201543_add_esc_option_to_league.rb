class AddEscOptionToLeague < ActiveRecord::Migration[5.2]
  def change
    add_column :leagues, :use_equitable_stroke_control, :boolean, default: true

    League.all.each do |l|
      l.update(use_equitable_stroke_control: l.calculate_handicaps_from_past_rounds)
    end
  end
end
