module TeamScrambleScoringRuleSetup
  def setup_partial
    'shared/game_type_setup/team_scramble'
  end

  def scorecard_score_cell_partial
    nil
  end

  def scorecard_post_embed_partial
    nil
  end

  def handicap_percentage_key
    "HandicapPercentageKey-T-#{id}-GT-6"
  end

  def use_back_nine_key
    "ShouldUseBackNineForTies-T-#{id}-GT-6"
  end

  def save_setup_details(game_type_options)
    handicap_percentage = game_type_options['handicap_percentage']

    metadata = GameTypeMetadatum.find_or_create_by(search_key: handicap_percentage_key)
    metadata.float_value = handicap_percentage
    metadata.save

    should_use_back_nine_for_ties = 0
    should_use_back_nine_for_ties = 1 if game_type_options['use_back_9_to_handle_ties'] == 'true'

    metadata = GameTypeMetadatum.find_or_create_by(search_key: use_back_nine_key)
    metadata.integer_value = should_use_back_nine_for_ties
    metadata.save
  end

  def remove_game_type_options
    metadata = GameTypeMetadatum.find_by(search_key: handicap_percentage_key)
    metadata.destroy if metadata.present?

    metadata = GameTypeMetadatum.find_by(search_key: use_back_nine_key)
    metadata.destroy if metadata.present?
  end

  def current_handicap_percentage
    metadata = GameTypeMetadatum.find_by(search_key: handicap_percentage_key)

    if metadata.blank?
      '0.0'
    else
      metadata.float_value
    end
  end

  def use_back_9_to_break_ties?
    metadata = GameTypeMetadatum.find_by(search_key: use_back_nine_key)

    if metadata.present? && metadata.integer_value == 1
      true
    else
      false
    end
  end
end
