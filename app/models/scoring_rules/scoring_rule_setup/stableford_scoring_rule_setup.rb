module StablefordScoringRuleSetup
  def setup_component_name
    'individual_stableford'
  end
  
  def leaderboard_partial_name
    'stableford_leaderboard'
  end

  def score_key(prefix)
    "StablefordScore-#{tournament_day.id}-GT-3-#{prefix}"
  end

  def metadata_score(prefix)
    return nil if tournament_day.blank?

    metadata = GameTypeMetadatum.where(search_key: score_key(prefix)).first

    if metadata.present? && metadata.integer_value.present?
      metadata.integer_value
    else
      nil
    end
  end

  def double_eagle_score
    metadata_score = self.metadata_score('double_eagle_score')
    metadata_score.presence || 16
  end

  def eagle_score
    metadata_score = self.metadata_score('eagle_score')
    metadata_score.presence || 8
  end

  def birdie_score
    metadata_score = self.metadata_score('birdie_score')
    metadata_score.presence || 4
  end

  def par_score
    metadata_score = self.metadata_score('par_score')
    metadata_score.presence || 2
  end

  def bogey_score
    metadata_score = self.metadata_score('bogey_score')
    metadata_score.presence || 1
  end

  def double_bogey_score
    metadata_score = self.metadata_score('double_bogey_score')
    metadata_score.presence || 0
  end

  def score_types
    ['doubleEagleScore', 'eagleScore', 'birdieScore', 'parScore', 'bogeyScore', 'doubleBogeyScore']
  end

  def save_setup_details(game_type_options)
    score_types.each do |score_type|
      score = 0
      score = game_type_options[score_type]

      metadata = GameTypeMetadatum.find_or_create_by(search_key: score_key(score_type))
      metadata.integer_value = score
      metadata.save
    end
  end

  def remove_game_type_options
    score_types.each do |score_type|
      metadata = GameTypeMetadatum.find_by(search_key: score_key(score_type))
      metadata.destroy if metadata.present?
    end
  end

  def custom_configuration_params
    {
      double_eagle_score: double_eagle_score,
      eagle_score: eagle_score,
      birdie_score: birdie_score,
      par_score: par_score,
      bogey_score: bogey_score,
      double_bogey_score: double_bogey_score
    }
  end
end
