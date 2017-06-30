# config valid only for current version of Capistrano
lock '3.3.3'

set :application, 'sales_booking'
set :repo_url, 'ssh://xmo@10.1.1.172:2727/share/xmo/sales_booking'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
# set :branch,'development'
# set :branch,'add_order_pages'
set :branch,'dev_email_notice_and_order_operate'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/opt/sales_booking'

set :bundle_flags, '--deployment'

set :bundle_gemfile, -> { release_path.join('Gemfile') }

# Default value for :scm is :git
set :scm, :git

set :chruby_ruby, 'ruby-2.1.2'

set :bundle_binstubs, nil
# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml','log/sidekiq.log','config/boot_app.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push( 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'tmp/schedules','tmp/executer','vendor/bundle', 'public/system','public/uploads')

# Default value for default_env is {}
set :default_env, { path: "/opt/rubies/ruby-2.1.2/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do

  task :boot_sidekiq do
    on roles(:web), in: :sequence, wait: 3 do
      within release_path do
        execute "./closedsidekiq"
        execute :bundle,"exec sidekiq -e production -d -L log/sidekiq.log"
      end
    end
  end

  task :boot_email_receiver do
    on roles(:app), in: :sequence, wait: 3 do
      puts " ***boot email receiver*** "
      within release_path do
       # execute "./boot_email_receiver"
       # nohup bundle exec rails runner email_receiver.rb -e staging > /dev/null 2>&1 &
       execute :bundle,"exec rails runner email_receiver.rb -e production &"
      end
    end
  end

  task :restart_thin  do
    on roles(:web),in: :sequence, wait: 3 do
      within release_path do
        execute :bundle,"exec thin restart -C /opt/sales_booking/shared/config/boot_app.yml"
      end
    end

  end

  after :published, :boot_sidekiq

  # after :published, :boot_email_receiver

  # after :published, :restart_thin


end
