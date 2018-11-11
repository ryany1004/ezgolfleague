module StrokePlayScoringRuleSetup
	def setup_partial
		'shared/game_type_setup/individual_stroke_play'
	end

  def use_back_nine_key
   	"ShouldUseBackNineForTies-T-#{self.tournament_day.id}-GT-#{self.game_type_id}"
  end

  def save_setup_details(game_type_options)
    should_use_back_nine_for_ties = 0
    should_use_back_nine_for_ties = 1 if game_type_options['use_back_9_to_handle_ties'] == 'true'

    metadata = GameTypeMetadatum.find_or_create_by(search_key: use_back_nine_key)
    metadata.integer_value = should_use_back_nine_for_ties
    metadata.save
  end

  def remove_game_type_options
    metadata = GameTypeMetadatum.where(search_key: use_back_nine_key).first
    metadata.destroy unless metadata.blank?
  end

  def use_back_9_to_break_ties?
    metadata = GameTypeMetadatum.where(search_key: use_back_nine_key).first

    if !metadata.blank? && metadata.integer_value == 1
      true
    else
      false
    end
  end
end