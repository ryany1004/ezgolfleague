namespace :create_sample_data do

  desc 'Delete All Data'
  task remove: :environment do
    League.all.destroy_all
    Course.all.destroy_all
    User.all.destroy_all
    Tournament.all.destroy_all
  end

  desc 'Create Sample Data'
  task all: :environment do
    League.where(name: "Danny's League").destroy_all
    Course.where(name: "Bushwood").destroy_all
    User.where("email LIKE ?", "%sample.com").destroy_all
    
    l = League.create(name: "Danny's League")
    
    c = Course.create(name: "Bushwood", phone_number: "888-888-8888", street_address_1: "123 Main Street", city: "My Zone", us_state: "CA", postal_code: "11111")
    tee_box = CourseTeeBox.create(course: c, name: "Black", rating: 72.1, slope: 3)
    
    h1 = CourseHole.create(course: c, hole_number: 1, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h1, yardage: 200)
    
    h2 = CourseHole.create(course: c, hole_number: 2, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h2, yardage: 200)
    
    h3 = CourseHole.create(course: c, hole_number: 3, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h3, yardage: 200)
    
    h4 = CourseHole.create(course: c, hole_number: 4, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h4, yardage: 200)
    
    h5 = CourseHole.create(course: c, hole_number: 5, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h5, yardage: 200)
    
    h6 = CourseHole.create(course: c, hole_number: 6, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h6, yardage: 200)
    
    h7 = CourseHole.create(course: c, hole_number: 7, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h7, yardage: 200)
    
    h8 = CourseHole.create(course: c, hole_number: 8, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h8, yardage: 200)
    
    h9 = CourseHole.create(course: c, hole_number: 9, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h9, yardage: 200)
    
    h10 = CourseHole.create(course: c, hole_number: 10, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h10, yardage: 200)
    
    h11 = CourseHole.create(course: c, hole_number: 11, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h11, yardage: 200)
    
    h12 = CourseHole.create(course: c, hole_number: 12, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h12, yardage: 200)
    
    h13 = CourseHole.create(course: c, hole_number: 13, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h13, yardage: 200)
    
    h14 = CourseHole.create(course: c, hole_number: 14, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h14, yardage: 200)
    
    h15 = CourseHole.create(course: c, hole_number: 15, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h15, yardage: 200)
    
    h16 = CourseHole.create(course: c, hole_number: 16, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h16, yardage: 200)
    
    h17 = CourseHole.create(course: c, hole_number: 17, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h17, yardage: 200)
    
    h18 = CourseHole.create(course: c, hole_number: 18, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h18, yardage: 200)
    
    #Sample Users
    user_info = [
      {:email => 'sample1@sample.com', :first_name => "Bob", :last_name => "Higgenbottom"},
      {:email => 'sample2@sample.com', :first_name => "Larry", :last_name => "Crabapple"},
      {:email => 'sample3@sample.com', :first_name => "Stirling", :last_name => "Olson"},
      {:email => 'sample4@sample.com', :first_name => "Jake", :last_name => "Sutton"},
      {:email => 'sample5@sample.com', :first_name => "Jon", :last_name => "Evans"},
      {:email => 'sample6@sample.com', :first_name => "Sheehan", :last_name => "Commette"},
      {:email => 'sample7@sample.com', :first_name => "Sarah", :last_name => "Silvers"},
      {:email => 'sample8@sample.com', :first_name => "Bob", :last_name => "Lewis"},
      {:email => 'sample9@sample.com', :first_name => "Barry", :last_name => "Anners"},
      {:email => 'sample10@sample.com', :first_name => "Jon", :last_name => "Snow"},
      {:email => 'sample11@sample.com', :first_name => "Ben", :last_name => "McKenzie"},
      {:email => 'sample12@sample.com', :first_name => "Stan", :last_name => "Blach"},
      {:email => 'sample13@sample.com', :first_name => "Simone", :last_name => "Perez"},
      {:email => 'sample14@sample.com', :first_name => "Jack", :last_name => "Crack"},
      {:email => 'sample15@sample.com', :first_name => "Steve", :last_name => "Cook"},
      {:email => 'sample16@sample.com', :first_name => "Phil", :last_name => "Schiller"},
      {:email => 'sample17@sample.com', :first_name => "Myke", :last_name => "Hurley"},
      {:email => 'sample18@sample.com', :first_name => "Katie", :last_name => "Cotton"},
      {:email => 'sample19@sample.com', :first_name => "Jonas", :last_name => "Gruber"},
    ]
    
    sample_users = []
    user_info.each do |u|
      u1 = User.create(email: u[:email], password: "This is not a real password", first_name: u[:first_name], last_name: u[:last_name], current_league: l)
      sample_users << u1
    end

    User.all.each do |u|
      m = LeagueMembership.create(league: l, user: u, is_admin: false)
    end
    
    tournament_info = [{:name => "Peachwood Open", :tournament_at => DateTime.now, :create_scores => true}, {:name => "Scalleywag Cup", :tournament_at => DateTime.now + 1.month, :create_scores => false}, {:name => "Caddy Day", :tournament_at => DateTime.now - 1.month, :create_scores => true}]
    tournament_info.each do |ti|
      t = Tournament.create(league: l, course: c, name: ti[:name], tournament_at: ti[:tournament_at], signup_opens_at: ti[:tournament_at] - 1.month, signup_closes_at: ti[:tournament_at] - 1.day, max_players: 100, mens_tee_box: c.course_tee_boxes.first, womens_tee_box: c.course_tee_boxes.first)
      
      c.course_holes.each do |c|
        t.course_holes << c
        t.save
      end

      group = TournamentGroup.create(tournament: t, tee_time_at: ti[:tournament_at], max_number_of_players: 4)

      sample_users.each_with_index do |u, i|
        group.reload
        
        if group.players_signed_up.count >= group.max_number_of_players
          group = TournamentGroup.create(tournament: t, tee_time_at: group.tee_time_at + 8.minutes, max_number_of_players: 4)
        end
        
        t.add_player_to_group(group, u)
    
        if ti[:create_scores] == true
          scorecard = t.primary_scorecard_for_user(u)
          unless scorecard.blank?      
            scorecard.scores.each do |score|
              score.strokes = Random.rand(4) + 1
              score.save
            end
          else
            puts "No Scorecard for #{u.id}"
          end
        end
      end
    end
  end
  
end