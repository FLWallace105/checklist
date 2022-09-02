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

    product_array = Array.new

    puts "#{@api_key}, #{@secret}, #{@shopname}, #{@app_token}"


      ShopifyAPI::Context.setup(
        api_key: "DUMMY",
        api_secret_key: @app_token,
        scope: "DUMMY",
        host_name: "DUMMY",
        private_shop: "#{@shopname}.myshopify.com",
        session_storage: ShopifyAPI::Auth::FileSessionStorage.new,
        is_embedded: false, 
        is_private: true, 
        api_version: "2022-07"
        
      )

      product_count = ShopifyAPI::Product.count()
      puts "product_count = #{product_count.inspect}"

      puts "We have #{product_count.body['count']} products in Ellie now"

      puts "----------------"

      puts "We have #{product_count.body['count']} products"

      my_today = DateTime.now.strftime("%B %Y")
      monthly_collection = "#{my_today} Collections"

      

      my_collection = ShopifyAPI::CustomCollection.all(title: monthly_collection)
      puts "my_collection = #{my_collection.inspect}"
      

      puts my_collection.first.original_state[:id]
      collection_id = my_collection.first.original_state[:id]

      product_count = ShopifyAPI::Product.count(:collection_id => collection_id).body['count']

      puts "We have #{product_count} products in the collection"

      

      my_products = ShopifyAPI::Product.all( collection_id: collection_id,  limit: 250 )
      num_products = 0

      
      

      
      

      my_products.each do |myp|
        puts "-----"
        #puts "product_id: #{myp.original_state[:id]} product_title: #{myp.original_state[:title]}, price: #{myp.variants.first.original_state[:price]}"
        num_products  += 1
        # puts "***************"
        # puts myp.inspect
        # puts "**************"

        mymeta = ShopifyAPI::Metafield.all(resource: 'products', resource_id: myp.original_state[:id], namespace: 'ellie_order_info', fields: 'value')
        # #note, it could be just []
        #puts "mymeta = #{mymeta}"
        # #make sure we assign a value to the string we pass in later
        my_meta_str = nil
        if mymeta != []
          my_meta_str = mymeta.first.original_state[:value]
        else
          my_meta_str = nil
        end
  
        puts "product_id: #{myp.original_state[:id]}, variant_id: #{myp.variants.first.original_state[:id]}, sku: #{myp.variants.first.original_state[:sku]}, product_title: #{myp.original_state[:title]}, price: #{myp.variants.first.original_state[:price]}, metafield: #{my_meta_str}, published_at: #{myp.original_state[:published_at]}}"

        my_hash = {"product_title" => myp.original_state[:title], "product_id" => myp.original_state[:id], "variant_id" => myp.variants.first.original_state[:id], "sku" => myp.variants.first.original_state[:sku], "price" => myp.variants.first.original_state[:price], "product_collection" => my_meta_str, "published_at" => myp.original_state[:published_at]}
        
        product_array.push(my_hash)
  
      end

      puts "here we have #{num_products} number of products"
      puts "done with first loop"
      
      if product_count > 250

      while my_products.next_page?

        my_products = my_products.fetch_next_page
      
        my_products.each do |myp|
          puts "--SECOND LOOP ---"
          mymeta = ShopifyAPI::Metafield.all(resource: 'products', resource_id: myp.original_state[:id], namespace: 'ellie_order_info', fields: 'value')
          # #note, it could be just []
          #puts "mymeta = #{mymeta}"
          # #make sure we assign a value to the string we pass in later
          my_meta_str = nil
          if mymeta != []
            my_meta_str = mymeta.first.original_state[:value]
          else
            my_meta_str = nil
          end
  
          puts "product_id: #{myp.original_state[:id]}, variant_id: #{myp.variants.first.original_state[:id]}, sku: #{myp.variants.first.original_state[:sku]}, product_title: #{myp.original_state[:title]}, price: #{myp.variants.first.original_state[:price]}, metafield: #{my_meta_str}, published_at: #{myp.original_state[:published_at]}}"
          
          my_hash = {"product_title" => myp.original_state[:title], "product_id" => myp.original_state[:id], "variant_id" => myp.variants.first.original_state[:id], "sku" => myp.variants.first.original_state[:sku], "price" => myp.variants.first.original_state[:price], "product_collection" => my_meta_str, "published_at" => myp.original_state[:published_at]}
        
          product_array.push(my_hash)
          
          
  
        end
      end
    end

    product_array.each do |myp|
      puts "-------------"
      puts myp
      puts "-------------"

      my_collection = ShopifyAPI::CustomCollection.all(title: myp['product_collection'])
      puts "my_collection = #{my_collection.inspect}"
      puts my_collection.first.original_state[:id]
      collection_id = my_collection.first.original_state[:id]
      product_count = ShopifyAPI::Product.count(:collection_id => collection_id).body['count']
      puts "We have #{product_count} products in the collection"

      product_title_number = 0

      if /(\d\s)/i =~ myp['product_title']
        product_title_number = $1.to_i
        puts "product_title_number = #{product_title_number}"
      end
      if product_title_number == product_count.to_i
        puts "Products in the collection match what they should be, products in collection = #{product_title_number}, prods in collection = #{product_count}"
      else
        puts "ERROR, product_count does not match the collection: products in collection = #{product_title_number}, prods in collection = #{product_count}"
      end

      my_products = ShopifyAPI::Product.all( collection_id: collection_id,  limit: 250 )
      

    end

    end

end
end