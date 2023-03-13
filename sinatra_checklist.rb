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

  #helpers Sinatra::PromoNotes::Helpers


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


end