module StrokePlayScoringRuleSetup
  def setup_component_name
    'individual_stroke_play'
  end

  def use_back_nine_key
    if tournament_day.blank?
      true
    else
      "ShouldUseBackNineForTies-T-#{tournament_day.id}-#{id}"
    end
  end

  def legacy_use_back_nine_key
    "ShouldUseBackNineForTies-T-#{tournament_day.id}-1"
  end

  def save_setup_details(game_type_options)
    if game_type_options['nineHoleTiebreaking']
      metadata = GameTypeMetadatum.find_or_create_by(search_key: use_back_nine_key)
      metadata.integer_value = 1
      metadata.save
    else
      remove_game_type_options
    end
  end

  def remove_game_type_options
    metadata = GameTypeMetadatum.find_by(search_key: use_back_nine_key)
    metadata.destroy if metadata.present?
  end

  def use_back_9_to_break_ties?
    metadata = GameTypeMetadatum.find_by(search_key: use_back_nine_key)

    if metadata.present? && metadata.integer_value == 1
      true
    else
      false
    end
  end

  def custom_configuration_params
    { nine_hole_tiebreaking: use_back_9_to_break_ties? }
  end
end
