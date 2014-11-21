namespace :rails do
  task :console do
    on roles(:app) do |h|
      run_interactively "bundle exec rails console #{fetch(:rails_env)}", h.user
    end
  end
end

def run_interactively(command, user)
  info "Running `#{command}` as #{user}@#{host}"
  exec %Q(ssh #{user}@#{host} -t "bash --login -c 'cd #{fetch(:deploy_to)}/current && #{command}'")
end
