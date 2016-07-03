# config valid only for current version of Capistrano
lock '3.5.0'

set :application, 'twighorse'
set :scm, :git
set :repo_url, 'git@github.com:brucebotes/so_auth.git'
set :deploy_to, "/home/admin/so_auth"
set :deploy_via, :remote_cache #this setting will only deploy diffs from git
set :format, :pretty
set :log_level, :debug
set :keep_releases, 2
