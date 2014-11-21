namespace :log do
  desc "tail production log files" 
  task :watch do
    on roles(:app) do
      execute "tail -f #{shared_path}/log/#{fetch(:rails_env)}.log"
    end
  end
end
