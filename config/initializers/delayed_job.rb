Delayed::Worker.delay_jobs = !%w[ test ].include?(Rails.env)
Delayed::Worker.max_attempts = 2