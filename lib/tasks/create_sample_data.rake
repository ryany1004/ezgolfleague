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
    
    l = League.create(name: "Danny's League", dues_amount: 20.00)
    
    c = Course.create(name: "Bushwood", phone_number: "888-888-8888", street_address_1: "123 Main Street", city: "My Zone", us_state: "CA", postal_code: "11111")
    tee_box = CourseTeeBox.create(course: c, name: "Men's Green", rating: 71.3, slope: 130, tee_box_gender: "Men")
    
    h1 = CourseHole.create(course: c, hole_number: 1, par: 4, mens_handicap: 5, womens_handicap: 5)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h1, yardage: 447)
    
    h2 = CourseHole.create(course: c, hole_number: 2, par: 3, mens_handicap: 17, womens_handicap: 17)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h2, yardage: 143)
    
    h3 = CourseHole.create(course: c, hole_number: 3, par: 4, mens_handicap: 11, womens_handicap: 11)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h3, yardage: 340)
    
    h4 = CourseHole.create(course: c, hole_number: 4, par: 4, mens_handicap: 1, womens_handicap: 9)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h4, yardage: 347)
    
    h5 = CourseHole.create(course: c, hole_number: 5, par: 5, mens_handicap: 3, womens_handicap: 1)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h5, yardage: 568)
    
    h6 = CourseHole.create(course: c, hole_number: 6, par: 3, mens_handicap: 15, womens_handicap: 15)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h6, yardage: 149)
    
    h7 = CourseHole.create(course: c, hole_number: 7, par: 5, mens_handicap: 9, womens_handicap: 3)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h7, yardage: 533)
    
    h8 = CourseHole.create(course: c, hole_number: 8, par: 4, mens_handicap: 7, womens_handicap: 7)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h8, yardage: 439)
    
    h9 = CourseHole.create(course: c, hole_number: 9, par: 3, mens_handicap: 13, womens_handicap: 13)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h9, yardage: 207)
    
    h10 = CourseHole.create(course: c, hole_number: 10, par: 5, mens_handicap: 2, womens_handicap: 2)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h10, yardage: 577)
    
    h11 = CourseHole.create(course: c, hole_number: 11, par: 3, mens_handicap: 18, womens_handicap: 10)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h11, yardage: 183)
    
    h12 = CourseHole.create(course: c, hole_number: 12, par: 4, mens_handicap: 6, womens_handicap: 18)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h12, yardage: 286)
    
    h13 = CourseHole.create(course: c, hole_number: 13, par: 4, mens_handicap: 10, womens_handicap: 16)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h13, yardage: 322)
    
    h14 = CourseHole.create(course: c, hole_number: 14, par: 5, mens_handicap: 4, womens_handicap: 4)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h14, yardage: 526)
    
    h15 = CourseHole.create(course: c, hole_number: 15, par: 4, mens_handicap: 8, womens_handicap: 8)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h15, yardage: 394)
    
    h16 = CourseHole.create(course: c, hole_number: 16, par: 4, mens_handicap: 16, womens_handicap: 12)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h16, yardage: 391)
    
    h17 = CourseHole.create(course: c, hole_number: 17, par: 3, mens_handicap: 14, womens_handicap: 6)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h17, yardage: 212)
    
    h18 = CourseHole.create(course: c, hole_number: 18, par: 4, mens_handicap: 12, womens_handicap: 14)
    CourseHoleTeeBox.create(course_tee_box: tee_box, course_hole: h18, yardage: 353)
    
    #Sample Users
    user_info = [
      {:email => 'sample1@sample.com', :first_name => "Bob", :last_name => "Higgenbottom", :handicap_index => 10.4},
      {:email => 'sample2@sample.com', :first_name => "Larry", :last_name => "Crabapple", :handicap_index => 11.2},
      {:email => 'sample3@sample.com', :first_name => "Stirling", :last_name => "Olson", :handicap_index => 9.4},
      {:email => 'sample4@sample.com', :first_name => "Jake", :last_name => "Sutton", :handicap_index => 18.4},
      {:email => 'sample5@sample.com', :first_name => "Jon", :last_name => "Evans", :handicap_index => 5.4},
      {:email => 'sample6@sample.com', :first_name => "Sheehan", :last_name => "Commette", :handicap_index => 3.4},
      {:email => 'sample7@sample.com', :first_name => "Sarah", :last_name => "Silvers", :handicap_index => 6.4},
      {:email => 'sample8@sample.com', :first_name => "Bob", :last_name => "Lewis", :handicap_index => 11.4},
      {:email => 'sample9@sample.com', :first_name => "Barry", :last_name => "Anners", :handicap_index => 14.4},
      {:email => 'sample10@sample.com', :first_name => "Jon", :last_name => "Snow", :handicap_index => 15.4},
      {:email => 'sample11@sample.com', :first_name => "Ben", :last_name => "McKenzie", :handicap_index => 16.8},
      {:email => 'sample12@sample.com', :first_name => "Stan", :last_name => "Blach", :handicap_index => 23.9},
      {:email => 'sample13@sample.com', :first_name => "Simone", :last_name => "Perez", :handicap_index => 22.1},
      {:email => 'sample14@sample.com', :first_name => "Jack", :last_name => "Crack", :handicap_index => 12.2},
      {:email => 'sample15@sample.com', :first_name => "Steve", :last_name => "Cook", :handicap_index => 13.4},
      {:email => 'sample16@sample.com', :first_name => "Phil", :last_name => "Schiller", :handicap_index => 16.4},
      {:email => 'sample17@sample.com', :first_name => "Myke", :last_name => "Hurley", :handicap_index => 36.4},
      {:email => 'sample18@sample.com', :first_name => "Katie", :last_name => "Cotton", :handicap_index => 22.9},
      {:email => 'sample19@sample.com', :first_name => "Jonas", :last_name => "Gruber", :handicap_index => 30.1},
    ]
    
    sample_users = []
    user_info.each do |u|
      u1 = User.create(email: u[:email], password: "This is not a real password", first_name: u[:first_name], last_name: u[:last_name], current_league: l, handicap_index: u[:handicap_index])
      sample_users << u1
    end

    User.all.each do |u|
      m = LeagueMembership.create(league: l, user: u, is_admin: false)
    end
    
    tournament_info = [{:name => "Peachwood Open", :tournament_at => DateTime.now, :create_scores => true, :finalize_tournament => false}, {:name => "Scalleywag Cup", :tournament_at => DateTime.now + 1.month, :create_scores => false, :finalize_tournament => false}, {:name => "Caddy Day", :tournament_at => DateTime.now - 1.month, :create_scores => true, :finalize_tournament => true}]
    
    tournament_info.each do |ti|
      t = Tournament.create(league: l, course: c, name: ti[:name], max_players: 100, dues_amount: 20.0) {|h|
        h.update_attribute('tournament_at', ti[:tournament_at])
        h.update_attribute('signup_opens_at', ti[:tournament_at] - 1.month)
        h.update_attribute('signup_closes_at', ti[:tournament_at] - 1.day)
      }
      
      c.course_holes.each do |c|
        t.course_holes << c
        t.save
      end

      group = TournamentGroup.create(tournament: t, tee_time_at: ti[:tournament_at], max_number_of_players: 4)

      #create scores
      sample_users.each_with_index do |u, i|
        group.reload
        
        if group.players_signed_up.count >= group.max_number_of_players
          group = TournamentGroup.create(tournament: t, tee_time_at: group.tee_time_at + 8.minutes, max_number_of_players: 4)
        end
        
        t.add_player_to_group(group, u, c.course_tee_boxes.first)
        t.is_finalized = ti[:finalize_tournament] == true
        t.save
    
        if ti[:create_scores] == true          
          scorecard = t.primary_scorecard_for_user(u)
      
          if Random.rand(2) == 0
            scorecard.is_confirmed = false
          else
            scorecard.is_confirmed = true
          end
 
          scorecard.save
          
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
      
      group = TournamentGroup.create(tournament: t, tee_time_at: t.tournament_groups.last.tee_time_at + 8.minutes, max_number_of_players: 4)
      
      #create flights
      f1 = Flight.create(flight_number: 1, tournament: t, lower_bound: 0, upper_bound: 12, course_tee_box: c.course_tee_boxes.first)
      f2 = Flight.create(flight_number: 2, tournament: t, lower_bound: 13, upper_bound: 20, course_tee_box: c.course_tee_boxes.first)
      f3 = Flight.create(flight_number: 3, tournament: t, lower_bound: 21, upper_bound: 100, course_tee_box: c.course_tee_boxes.first)
      t.assign_players_to_flights
      
      #payouts      
      f1.reload
      f2.reload
      f3.reload
      
      p1 = Payout.create(flight: f1, sort_order: 0, amount: 45.00, points: 45.0)
      
      if t.tournament_at < DateTime.now
        p1.user = f1.users[0]
        p1.save
      end
      
      p2 = Payout.create(flight: f1, sort_order: 1, amount: 25.00, points: 25.0)
      
      if t.tournament_at < DateTime.now
        p2.user = f1.users[1]
        p2.save
      end
      
      p3 = Payout.create(flight: f1, sort_order: 2, amount: 15.00, points: 15.0)
      
      if t.tournament_at < DateTime.now
        p3.user = f1.users[2]
        p3.save
      end
      
      p4 = Payout.create(flight: f2, sort_order: 0, amount: 45.00, points: 45.0)
      
      if t.tournament_at < DateTime.now
        p4.user = f2.users[0]
        p4.save
      end
      
      p5 = Payout.create(flight: f2, sort_order: 1, amount: 25.00, points: 25.0)
      
      if t.tournament_at < DateTime.now
        p5.user = f2.users[1]
        p5.save
      end
      
      p6 = Payout.create(flight: f2, sort_order: 2, amount: 15.00, points: 15.0)
      
      if t.tournament_at < DateTime.now
        p6.user = f2.users[2]
        p6.save
      end
      
      p7 = Payout.create(flight: f3, sort_order: 0, amount: 45.00, points: 45.0)
      
      if t.tournament_at < DateTime.now
        p7.user = f3.users[0]
        p7.save
      end
      
      p8 = Payout.create(flight: f3, sort_order: 1, amount: 25.00, points: 25.0)
      
      if t.tournament_at < DateTime.now
        p8.user = f3.users[1]
        p8.save
      end
      
      p9 = Payout.create(flight: f3, sort_order: 2, amount: 15.00, points: 15.0)
      
      if t.tournament_at < DateTime.now
        p9.user = f3.users[2]
        p9.save
      end
    end
  end
  
end