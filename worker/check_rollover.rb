# frozen_string_literal: true

require 'shopify_api'
require 'dotenv'
require 'json'

Dotenv.load
Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file }
#Dir[File.join(__dir__, 'models', '*.rb')].each { |file| require file }

# Create Promo Note Metafield for products at Shopify
class CheckRollover
  @queue = :create_checklist_csv
  extend ShopifyResources
  #extend ShopifyThrottle

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.perform(params)
    puts "Starting ..."
    puts "I have #{params}"
    email = params['email']

    shopname = ENV['SHOPIFY_SHOP_NAME']
    api_key = ENV['SHOPIFY_API_KEY']
    password = ENV['SHOPIFY_API_PASSWORD']
    secret = ENV['SHOPIFY_SHARED_SECRET']
    app_token = ENV['APP_TOKEN']

    product_array = Array.new

    puts "#{api_key}, #{secret}, #{shopname}, #{app_token}"


      ShopifyAPI::Context.setup(
        api_key: "DUMMY",
        api_secret_key: app_token,
        scope: "DUMMY",
        host_name: "DUMMY",
        private_shop: "#{shopname}.myshopify.com",
        session_storage: ShopifyAPI::Auth::FileSessionStorage.new,
        is_embedded: false, 
        is_private: true, 
        api_version: "2022-07"
        
      )

      

      get_shopify_checklist_data(email)



      puts "All done"


  end

end