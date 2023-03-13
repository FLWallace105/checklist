# config.ru (run with rackup)
require 'resque/server'
require 'dotenv/load'
require './sinatra_checklist'
run RolloverChecklist


Resque::Server.use Rack::Auth::Basic do |username, password|
    username == ENV['ADMIN_USER']
    password == ENV['ADMIN_PASSWORD']
end
 
  
run Rack::URLMap.new( '/resque' => Resque::Server.new, '/' => RolloverChecklist.new)