#checklist.rb
require 'dotenv'
require 'httparty'
require 'shopify_api'
require 'active_record'
require 'sinatra/activerecord'
#require 'logger'

Dotenv.load
Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'models', '*.rb')].each { |file| require file }

module Checklist
  class ShopifyGetter
    
    

    def initialize
      @shopname = ENV['SHOPIFY_SHOP_NAME']
      @api_key = ENV['SHOPIFY_API_KEY']
      @password = ENV['SHOPIFY_API_PASSWORD']
      @secret = ENV['SHOPIFY_SHARED_SECRET']
      @app_token = ENV['APP_TOKEN']

      
    end

    def shopify_get_all_resources
   
      puts "Starting all shopify resources download"
    #   shop_url = "https://#{@api_key}:#{@password}@#{@shopname}.myshopify.com/admin"
    #   puts shop_url
      
    #   ShopifyAPI::Base.site = shop_url
    #   ShopifyAPI::Base.api_version = '2020-04'
    #   ShopifyAPI::Base.timeout = 180

    puts "#{@api_key}, #{@secret}, #{@shopname}"


      ShopifyAPI::Context.setup(
        api_key: "DUMMY",
        api_secret_key: @app_token,
        scope: "DUMMY",
        host_name: "DUMMY",
        private_shop: "elliestaging.myshopify.com",
        session_storage: ShopifyAPI::Auth::FileSessionStorage.new,
        is_embedded: false, 
        is_private: true, 
        api_version: "2022-07"
        
      )

      product_count = ShopifyAPI::Product.count()

      puts "We have #{product_count.inspect} products in Ellie now"

      puts "----------------"

      puts "We have #{product_count.body['count']} products"

    end

end
end