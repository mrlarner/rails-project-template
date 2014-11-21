namespace :pow do
  desc "Restart Rails app for pow.cx"
  task :restart do
    puts "Restarting"
    `touch #{Rails.root}/tmp/restart.txt`
  end
end
