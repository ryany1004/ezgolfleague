namespace :create_sample_data do

  desc 'Create Sample Data'
  task all: :environment do
    League.where(name: "Sample League").destroy_all
    Course.where(name: "Sample Course").destroy_all
    User.where(email: "sample@sample.com").destroy_all
    
    l = League.create(name: "Sample League")
    
    c = Course.create(name: "Sample Course", phone_number: "888-888-8888", street_address_1: "123 Main Street", city: "My Zone", us_state: "CA", postal_code: "11111", rating: 72.1, slope: 3)
    h1 = CourseHole.create(course: c, hole_number: 1, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_hole: h1, name: "Black", yardage: 200)
    
    h2 = CourseHole.create(course: c, hole_number: 2, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_hole: h2, name: "Black", yardage: 200)
    
    h3 = CourseHole.create(course: c, hole_number: 3, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_hole: h3, name: "Black", yardage: 200)
    
    h4 = CourseHole.create(course: c, hole_number: 4, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_hole: h4, name: "Black", yardage: 200)
    
    h5 = CourseHole.create(course: c, hole_number: 5, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_hole: h5, name: "Black", yardage: 200)
    
    h6 = CourseHole.create(course: c, hole_number: 6, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_hole: h6, name: "Black", yardage: 200)
    
    h7 = CourseHole.create(course: c, hole_number: 7, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_hole: h7, name: "Black", yardage: 200)
    
    h8 = CourseHole.create(course: c, hole_number: 8, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_hole: h8, name: "Black", yardage: 200)
    
    h9 = CourseHole.create(course: c, hole_number: 9, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_hole: h9, name: "Black", yardage: 200)
    
    h10 = CourseHole.create(course: c, hole_number: 10, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_hole: h10, name: "Black", yardage: 200)
    
    h11 = CourseHole.create(course: c, hole_number: 11, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_hole: h11, name: "Black", yardage: 200)
    
    h12 = CourseHole.create(course: c, hole_number: 12, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_hole: h12, name: "Black", yardage: 200)
    
    h13 = CourseHole.create(course: c, hole_number: 13, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_hole: h13, name: "Black", yardage: 200)
    
    h14 = CourseHole.create(course: c, hole_number: 14, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_hole: h14, name: "Black", yardage: 200)
    
    h15 = CourseHole.create(course: c, hole_number: 15, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_hole: h15, name: "Black", yardage: 200)
    
    h16 = CourseHole.create(course: c, hole_number: 16, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_hole: h16, name: "Black", yardage: 200)
    
    h17 = CourseHole.create(course: c, hole_number: 17, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_hole: h17, name: "Black", yardage: 200)
    
    h18 = CourseHole.create(course: c, hole_number: 18, par: 1, mens_handicap: 1, womens_handicap: 3)
    CourseHoleTeeBox.create(course_hole: h18, name: "Black", yardage: 200)
    
    t = Tournament.create(league: l, course: c, name: "Sample Tournament", tournament_at: DateTime.now + 1.month, signup_opens_at: DateTime.now, signup_closes_at: DateTime.now + 29.days, max_players: 100, mens_tee_box: "Black")
    g1 = TournamentGroup.create(tournament: t, tee_time_at: DateTime.now + 31.days, max_number_of_players: 4)
    TournamentGroup.create(tournament: t, tee_time_at: DateTime.now + 31.days + 15.minutes, max_number_of_players: 4)

    c.course_holes.each do |c|
      t.course_holes << c
      t.save
    end

    u = User.create(email: "sample@sample.com", password: "This is not a real password", first_name: "Test", last_name: "User", current_league: l)
    u.leagues << l
    u.save
    
    t.add_player_to_group(g1, u)
  end
  
end