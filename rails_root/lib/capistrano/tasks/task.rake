SSHKit.config.command_map[:rake] = "bundle exec rake"
namespace :task do  
  desc "Run a task on a remote server."  
  # run like: cap staging rake:invoke task=a_certain_task  
  task :invoke do
    on roles(:app) do
      # execute :cd, "#{current_path}"
      within release_path do
        # execute :rake, "db:migrate"
        execute :rake, "#{ENV['task']} RAILS_ENV=#{fetch(:stage)}"
      end
    end
  end  
end
