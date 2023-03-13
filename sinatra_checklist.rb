require 'sinatra/base'
require 'dotenv'
#require 'sinatra/activerecord'
require 'sinatra/flash'
require 'resque'

#require_relative 'marika_shopify'

Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file }
#Dir[File.join(__dir__, 'models', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'worker', '*.rb')].each { |file| require file }

class RolloverChecklist < Sinatra::Base
  Dotenv.load
  #register Sinatra::ActiveRecordExtension

  use Rack::Auth::Basic, 'Restricted Area' do |username, password|
    username == ENV['ADMIN_USER'] and password == ENV['ADMIN_PASSWORD']
  end

  enable :sessions
  register Sinatra::Flash

  helpers Sinatra::RolloverChecklist::Helpers


  before do
    cache_control :no_cache
    headers \
      "Pragma"   => "no-cache",
      "Expires" => "0"
  end

  

  get '/' do
    # "hello welcome to checklist"

    erb :index
  end

  post '/checklist' do
    puts "received checklist"
    puts "params = #{params.inspect}"
    sanitized_params = sanitize_params(params)
    puts "sanitized_params = #{sanitized_params}"
    flash[:alert_success] = 'Generating Checklist, check your email in about 15 minutes ...'
    Resque.enqueue_to(:create_checklist_csv, 'CheckRollover', sanitized_params)
    redirect "/"

  
  end


end