require 'resque/tasks'

Resque.logger = Logger.new("resque_running.log")

task "resque:setup" => :environment do
  ENV['QUEUE'] ||= '*'
  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end