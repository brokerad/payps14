# set :git_account, Proc.new { Capistrano::CLI.password_prompt('github user?') }
# set :scm_passphrase,  Proc.new { Capistrano::CLI.password_prompt('github password?') }

default_run_options[:pty] = true
set :repository,  "git@github.com:Slytrade/slytrade.git"
set :scm, "git"

ssh_options[:forward_agent] = true
set :deploy_via, :checkout
set :use_sudo, false

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :migrate do
    run "#{rvm_cmd}; cd #{current_path}; rake db:migrate RAILS_ENV=#{rails_env}"
  end
  task :seed do
    run "#{rvm_cmd}; cd #{current_path}; rake db:seed RAILS_ENV=#{rails_env}"
  end
  task :reset do
    run "#{rvm_cmd}; cd #{current_path}; rake db:reset RAILS_ENV=#{rails_env}"
  end
  task :start do
    run "#{rvm_cmd}; thin -C #{thin_conf_file} start"
  end
  task :stop do
    run "#{rvm_cmd}; thin -C #{thin_conf_file} stop"
  end
  task :restart do
    run "#{rvm_cmd}; thin -C #{thin_conf_file} -O restart"
  end
  task :bundle_install do
    run "#{rvm_cmd}; cd #{current_path}; bundle install"
    # run "#{rvm_cmd}; cd #{current_path}; bundle install --local"
  end
  task :compile_less do
    run "#{rvm_cmd}; cd #{current_path}/public/stylesheets/lib/; lessc bootstrap.publisher.less > ../bootstrap.publisher.css"
  end
  task :coverage_report do
    run "rake generate_code_coverage"
  end

  task :shared_folders_symlinks do
    run "ln -nfs #{shared_path}/uploads #{current_path}/public/uploads"
  end

end

task :production do
  set :application, "paypersocial"
  role :app, "tool.paypersocial.com"
  role :web, "tool.paypersocial.com"
  role :db, "tool.paypersocial.com"
  set :user, "paypersocial"
  set :deploy_to, "/srv/http/tool.paypersocial.com"
  set :thin_conf_file, "/etc/thin/tool.paypersocial.com.yml"
  set :rvm_cmd, "source ~/.rvm/scripts/rvm; rvm use 1.8.7@paypersocial"
  set :rails_env, "production"
  set :branch, "master_deploy"
end

task :qa do
  set :application, "slytrade"
  role :web, "qa.slytrade.com"                          # Your HTTP server, Apache/etc
  role :app, "qa.slytrade.com"                          # This may be the same as your `Web` server
  role :db,  "qa.slytrade.com", :primary => true # This is where Rails migrations will run
  set :user, "slytrade"
  set :deploy_to, "/srv/http/qa.slytrade.com"
  set :thin_conf_file, "/etc/thin/qa.slytrade.com.yml"
  set :rvm_cmd, "source ~/.rvm/scripts/rvm; rvm use 1.8.7@paypersocial"
  set :rails_env, "qa"
  set :branch, "master_deploy"
end

after "deploy:create_symlink", "deploy:shared_folders_symlinks",
      "deploy:bundle_install", "deploy:migrate", "deploy:seed", "deploy:compile_less"
