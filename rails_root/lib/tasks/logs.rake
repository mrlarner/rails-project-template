namespace :log do
  desc "Watch log"
  task :watch do
    puts "Watching log..."
    system("tail -f #{Rails.root}/log/#{Rails.env}.log")
  end
end
