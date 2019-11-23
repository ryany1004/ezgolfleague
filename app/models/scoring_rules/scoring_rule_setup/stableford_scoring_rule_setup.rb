module StablefordScoringRuleSetup
  def setup_component_name
    'individual_stableford'
  end
  
  def leaderboard_partial_name
    'stableford_leaderboard'
  end

  def score_key(prefix)
    return "StablefordScore-#{self.tournament_day.id}-GT-3-#{prefix}"
  end

  def metadata_score(prefix)
    metadata = GameTypeMetadatum.where(search_key: self.score_key(prefix)).first

    if !metadata.blank? && !metadata.integer_value.blank?
      metadata.integer_value
    else
      nil
    end
  end

  def double_eagle_score
    metadata_score = self.metadata_score("double_eagle_score")

    unless metadata_score.blank?
      metadata_score
    else
      return 16
    end
  end

  def eagle_score
    metadata_score = self.metadata_score("eagle_score")

    unless metadata_score.blank?
      metadata_score
    else
      return 8
    end
  end

  def birdie_score
    metadata_score = self.metadata_score("birdie_score")

    unless metadata_score.blank?
      metadata_score
    else
      return 4
    end
  end

  def par_score
    metadata_score = self.metadata_score("par_score")

    unless metadata_score.blank?
      metadata_score
    else
      return 2
    end
  end

  def bogey_score
    metadata_score = self.metadata_score("bogey_score")

    unless metadata_score.blank?
      metadata_score
    else
      return 1
    end
  end

  def double_bogey_score
    metadata_score = self.metadata_score("double_bogey_score")

    unless metadata_score.blank?
      metadata_score
    else
      return 0
    end
  end

  def save_setup_details(game_type_options)
    score_types = ["double_eagle_score", "eagle_score", "birdie_score", "par_score", "bogey_score", "double_bogey_score"]
    score_types.each do |score_type|
      score = 0
      score = game_type_options[score_type]

      metadata = GameTypeMetadatum.find_or_create_by(search_key: self.score_key(score_type))
      metadata.integer_value = score
      metadata.save
    end
  end

  def remove_game_type_options
    score_types = ["double_eagle_score", "eagle_score", "birdie_score", "par_score", "bogey_score", "double_bogey_score"]
    score_types.each do |score_type|
      metadata = GameTypeMetadatum.where(search_key: self.score_key(score_type)).first
      metadata.destroy unless metadata.blank?
    end
  end
end