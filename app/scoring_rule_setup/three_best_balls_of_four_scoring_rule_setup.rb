module ThreeBestBallsOfFourScoringRuleSetup
  def setup_component_name
    'three_best_balls_of_four'
  end

  def should_add_par_key
    if tournament_day.blank?
      nil
    else
      "ShouldAddParIfNotEnoughScores-T-#{tournament_day.id}-#{id}"
    end
  end

  def save_setup_details(game_type_options)
    should_add_par_if_small_group = 0
    should_add_par_if_small_group = 1 if game_type_options['shouldAddParIfSmallGroup'] == 'true'

    metadata = GameTypeMetadatum.find_or_create_by(search_key: should_add_par_key)
    metadata.integer_value = should_add_par_if_small_group
    metadata.save
  end

  def remove_game_type_options
    metadata = GameTypeMetadatum.find_by(search_key: should_add_par_key)
    metadata.destroy if metadata.present?
  end

  def should_add_par?
    metadata = GameTypeMetadatum.find_by(search_key: should_add_par_key)

    if metadata.present? && metadata.integer_value == 1
      true
    else
      false
    end
  end

  def custom_configuration_params
    { shouldAddParIfSmallGroup: should_add_par? }
  end
end
