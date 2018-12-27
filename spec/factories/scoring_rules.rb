FactoryBot.define do
  factory :scoring_rule do
  	is_opt_in { false }

    after(:create) do |scoring_rule|
      scoring_rule.course_holes << CourseHole.all
    end

    factory :individual_stroke_play_scoring_rule, class: StrokePlayScoringRule do
    	dues_amount { 30.0 }
    end

    factory :individual_modified_stableford_scoring_rule, class: StablefordScoringRule do
    end
  end
end