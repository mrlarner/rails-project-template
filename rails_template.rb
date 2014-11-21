def source_paths
  [File.expand_path(File.join(File.dirname(__FILE__), 'rails_root'))]
end

create_file ".ruby-version", "2.1.1"

template '.env.erb', '.env'

# ditch sqlite
gsub_file "Gemfile", /^gem\s+["']sqlite3["'].*$/,''
# ditch turbolinks
gsub_file "Gemfile", /^gem\s+["']turbolinks["'].*$/,''

# ruby v into gemfile
insert_into_file 'Gemfile', "\nruby '2.1.1'", after: "source 'https://rubygems.org'\n"

gem 'bourbon'
gem 'neat'
gem 'slim-rails'
gem 'high_voltage'
gem 'bower-rails'
gem 'normalize-rails'
gem 'formtastic'

gem 'unicorn'
gem 'pg'

gem 'devise'
gem 'cancan'
gem 'friendly_id'

gem_group :development do
  gem 'dotenv-rails'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano', '~> 3.2.1'
end

gem_group :test do
  gem 'dotenv-deployment'
  gem 'cucumber'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'poltergeist'
  gem 'database_cleaner'
end

gem_group :test, :development do
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'

  gem 'guard-rspec'
  gem 'guard-bundler'
  gem 'terminal-notifier-guard'
  gem 'rb-fsevent', require: false
end

gem_group :production do
  gem 'rails_12factor'
end

# install gems
run 'bundle install'


inside 'config' do

  insert_into_file 'environment.rb', "$stdout.sync = true\n", before: "# Load the rails application"

  insert_into_file 'application.rb',
    "\nconfig.assets.initialize_on_precompile = false\n",
    after: "class Application < Rails::Application"
  insert_into_file 'application.rb',
    "\nconfig.middleware.use Rack::Deflater\n",
    after: "class Application < Rails::Application"
  insert_into_file 'application.rb', after: "class Application < Rails::Application" do <<-CODE

    config.autoload_paths += %W(\#{config.root}/app/presenters \#{config.root}/app/decorators)

  CODE
  end
   
  # database config
  remove_file 'database.yml'
  copy_file 'database.yml'
  copy_file 'unicorn.rb'

  inside 'environments' do
    insert_into_file 'development.rb', "Rails.application.routes.default_url_options[:host]= '#{@app_name}.dev'\n\n", before: 'Rails.application.configure do'
    insert_into_file 'development.rb', "\n\nconfig.action_mailer.default_url_options = { host: '#{@app_name}.dev' }\n\n", after: 'Rails.application.configure do'
  end

  inside 'initializers' do
    copy_file 'assets.rb'
    copy_file 'secrets.rb'
  end
end

# heroku buildpacks for rails + bower
file '.buildpacks', <<-CODE
https://github.com/heroku/heroku-buildpack-nodejs.git
https://github.com/heroku/heroku-buildpack-ruby.git
CODE

# bower
generate 'bower_rails:initialize'
rake 'bower:install'

# cap
run 'bundle exec cap install STAGES=staging,production'
inside 'lib' do
  copy_file 'marker.rb'
  copy_file 'api_constraints.rb'
  inside 'tasks' do
    copy_file 'logs.rake'
    copy_file 'pow.rake'
  end
  inside 'capistrano' do
    inside 'tasks' do
      copy_file 'console.rake'
      copy_file 'log.rake'
      copy_file 'task.rake'
    end
  end
end

# specs
generate 'rspec:install'
remove_file '.rspec'
file '.rspec', <<-CODE
--color
--format progress
--format html -o "public/specs.html"
CODE

# create dbs
rake "db:create", :env => 'development'
rake "db:create", :env => 'test'

# authentication and authorization setup
generate "devise:install"
generate "devise User"
generate "devise:views"
rake "db:migrate"
generate "cancan:ability"

inside 'config' do
  insert_into_file 'routes.rb', after: "devise_for :users" do <<-CODE
  \n
  devise_scope :user do
    authenticated :user do
      root 'home#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end\n\n
  CODE
  end
end
generate :controller, "home index"
route "root to: 'home#index'"
# cleanup
remove_file 'public/index.html'
remove_file 'public/images/rails.png'

inside 'app' do
  run ' mkdir decorators'
  inside 'decorators' do
    copy_file 'base_decorator.rb'
  end
  run ' mkdir presenters'
  inside 'presenters' do
    copy_file 'base_presenter.rb'
  end
  inside 'assets' do
    run ' mkdir templates'
    inside 'javascripts' do
      gsub_file "application.js", /^\/\/=\s+require\s+turbolinks.*$/,''
    end
    inside 'stylesheets' do
      remove_file 'applications.css'
      copy_file 'application.sass'
    end
  end
  inside 'views' do
    inside 'layouts' do
      remove_file 'application.html.erb'
      template 'application.html.slim.erb', 'application.html.slim'
    end
  end

end

directory 'lib/generators/decorator'
directory 'lib/generators/presenter'


inside 'db' do
  append_to_file 'seeds.rb' do <<-CODE
@user = User.create! do |u|
  u.email = 'test@example.com'
  u.password = 'password'
  u.password_confirmation = 'password'
end
  CODE
end
end
rake 'db:migrate db:seed'

git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }

run 'ln -sf $(pwd) ~/.pow/'
