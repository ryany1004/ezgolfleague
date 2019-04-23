module ApplicationHelper

  def human_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end

  def show_subscription_needed?
  	!current_user.selected_league&.exempt_from_subscription && current_user.is_any_league_admin? && !current_user.selected_league&.has_active_subscription?
  end

  def has_active_subscription?
  	current_user.selected_league.present? ? current_user.selected_league.has_active_subscription? : false
  end

  def free_trial_remaining?
  	current_user.selected_league.present? ? current_user.selected_league.free_tournaments_remaining > 0 : false
  end

  def user_is_league_admin(user, league)
    return true if user.is_super_user

    return false if user.blank?
    return false if league.blank?

    membership = league.membership_for_user(user)

    unless membership.blank?
      return membership.is_admin
    else
      return false
    end
  end

  def current_league_name
    current_user.selected_league.name
  end

  def current_season_name
    current_user.selected_league&.active_season&.name
  end

  def current_user_is_admin_for_user(user)
    user_is_admin_of_any = false

    user.leagues.each do |league|
      if user_is_league_admin(current_user, league) == true
        user_is_admin_of_any = true
      end
    end

    user_is_admin_of_any
  end

  def tournament_paid(tournament, user)
    if tournament.user_has_paid?(user)
      ""
    else
      "(Unpaid)"
    end
  end

  def is_editable?(tournament)
    return true if tournament.league.try(:membership_for_user, current_user).try(:is_admin)
    return true if current_user.is_super_user?
    
    false
  end

  def bootstrap_class_for(flash_type)
    case flash_type
      when "success"
        "alert-success"   # Green
      when "error"
        "alert-danger"    # Red
      when "alert"
        "alert-warning"   # Yellow
      when "notice"
        "alert-info"      # Blue
      else
        flash_type.to_s
    end
  end

  def scorecard_score_helper(score, print_mode = false)
    if score.strokes != 0
      return score.strokes
    else
      if !score&.scorecard&.is_potentially_editable?
        return 0
      else
        if print_mode == true
          return ""
        else
          return "-"
        end
      end
    end
  end

  def par_helper(par)
    return nil if par.blank?

    if par == 0
      return "Even"
    elsif par > 0
      return "+#{par}"
    else
      return par
    end
  end

  def team_member_names_without_user(team, user)
    members = []

    team.golf_outings.each do |outing|
      members << outing.user unless members.include? outing.user or outing.user == user
    end

    names = ""

    members.each do |m|
      names = "#{names}#{m.complete_name}<br/>"
    end

    names.html_safe
  end

  def handicap_allowance_strokes_for_hole(handicap_allowance, course_hole)
    return 0 if handicap_allowance.blank?

    handicap_allowance.each do |h|
      if h[:course_hole] == course_hole
        return h[:strokes]
      end
    end

    0
  end

  def print_handicap_allowance_strokes_for_hole(handicap_allowance, course_hole)
    return "" if handicap_allowance.blank?

    pops = ""

    handicap_allowance.each do |h|
      if h[:course_hole] == course_hole
        if h[:strokes] == 1
          pops = "•"
        elsif h[:strokes] == 2
          pops = "••"
        else
          pops = "!"
        end
      end
    end

    pops
  end

  def tournament_class_for_stage(stage, stage_option)
    if stage == stage_option
      "class=active"
    else
      ""
    end
  end

  def cache_key_for_scorecard(scorecard_id)
    scorecard = Scorecard.find(scorecard_id)

    scorecard.cache_key
  end

  def team_member_names(daily_team, show_available_text = true)
    members = []

    daily_team.users.each do |user|
      members << user
    end

    names = ""

    members.each do |m|
      names = "#{names}#{m.complete_name}<br/>"
    end

    if show_available_text == true
      if daily_team.max_players == daily_team.users.count
        names = "#{names}<strong>Team Full</strong><br/>"
      else
        names = "#{names}<strong>Space Available</strong><br/>"
      end
    end

    names.html_safe
  end

  def handicap_allowance_for_scorecard(scorecard)
    if scorecard.golf_outing.blank?
      []
    else
      allowance = scorecard.tournament_day.handicap_allowance(user: scorecard.golf_outing.user)

      allowance
    end
  end

  def score_for_score_with_handicap_allowance(score, handicap_allowance)
    net_score = score.strokes - handicap_allowance_strokes_for_hole(handicap_allowance_for_scorecard(score.scorecard), score.course_hole)

    if net_score < 0
      0
    else
      net_score
    end
  end

  def score_print_helper(score, print_mode)
    if print_mode && score.zero?
      ""
    else
      score
    end
  end

  def flight_or_group(tournament)
    if tournament.league.allow_scoring_groups
      "Group"
    else
      "Flight"
    end
  end
end
