class PrintScorecardsJob < ProgressJob::Base
  def initialize(tournament_day, current_user)
    max_count = tournament_day.tournament.players_for_day(tournament_day).count

    super progress_max: max_count

    @tournament = tournament_day.tournament
    @tournament_day = tournament_day
    @current_user = current_user
  end

  def perform
    update_stage('Printing Scorecards')

    Rails.logger.info { "PrintScorecardsJob Started" }

    Rails.cache.write(@tournament_day.scorecard_print_cache_key, nil)

    @print_cards = []

    Rails.logger.info { "PrintScorecardsJob: Working Through Players" }

    @tournament.players_for_day(@tournament_day).each do |player|
      primary_scorecard = @tournament_day.primary_scorecard_for_user(player)
      other_scorecards = @tournament_day.related_scorecards_for_user(player, true)

      Rails.logger.info { "PrintScorecardsJob: Found Scorecards for Player: #{player.id}" }

      if other_scorecards.count < 4
        number_to_create = (4 - other_scorecards.count) - 1

        number_to_create.times do
          extra_scorecard = GameTypes::EmptyLineScorecard.new
          extra_scorecard.scores_for_course_holes(@tournament_day.course_holes)

          other_scorecards << extra_scorecard
        end
      end

      Rails.logger.info { "PrintScorecardsJob: Adding to Print Cards" }

      scorecard_presenter = Presenters::ScorecardPresenter.new({primary_scorecard: primary_scorecard, secondary_scorecards: other_scorecards, current_user: @current_user})

      @print_cards << {p: scorecard_presenter} if !self.printable_cards_includes_player?(@print_cards, player)

      update_progress
    end

    Rails.logger.info { "PrintScorecardsJob: Writing" }

    #NOTE: in Rails 5, move to standard solution
    body = ApplicationController.render 'prints/print_template_scorecards', locals: { :print_cards => @print_cards }, :layout => false

    Rails.cache.write(@tournament_day.scorecard_print_cache_key, body) unless body.blank?

    Rails.logger.info { "PrintScorecardsJob Completed" }
  end

  def printable_cards_includes_player?(printable_cards, player)
    printable_cards.each do |card|
      return true if card[:p].primary_scorecard.golf_outing.user == player

      card[:p].secondary_scorecards.each do |other|
        unless other.golf_outing.blank?
          return true if other.golf_outing.user == player
        end
      end
    end

    return false
  end

end
