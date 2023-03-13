# frozen_string_literal: true

require 'dotenv/load'

root = "#{Dir.getwd}"
shared_dir = "#{root}/tmp"
threads_count = Integer(ENV['MAX_THREADS'])

workers Integer(ENV['WEB_CONCURRENCY'])
threads threads_count, threads_count

preload_app!

rackup "#{root}/config.ru"
port ENV['PORT']
environment ENV['RACK_ENV']

bind "unix://#{shared_dir}/puma/socket"
stdout_redirect "#{shared_dir}/puma/stdout.log", "#{shared_dir}/puma/stderr.log", true
pidfile "#{shared_dir}/puma/pid"
state_path "#{shared_dir}/puma/state"

activate_control_app