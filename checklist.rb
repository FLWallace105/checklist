#checklist.rb
require 'dotenv'
require 'httparty'
require 'shopify_api'
# require 'active_record'
# require 'sinatra/activerecord'
#require 'logger'
require 'sendgrid-ruby'
require 'sinatra'


Dotenv.load
# Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file }
# Dir[File.join(__dir__, 'models', '*.rb')].each { |file| require file }

module Checklist
  class ShopifyGetter
    include SendGrid
    

    def initialize
      @shopname = ENV['SHOPIFY_SHOP_NAME']
      @api_key = ENV['SHOPIFY_API_KEY']
      @password = ENV['SHOPIFY_API_PASSWORD']
      @secret = ENV['SHOPIFY_SHARED_SECRET']
      @app_token = ENV['APP_TOKEN']

      
    end

    def shopify_get_all_resources(myemail)
   
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


      my_start_month_plus = Date.today 
      #my_start_month_plus = my_start_month_plus >> 1

      my_today = my_start_month_plus.strftime("%B %Y")
      monthly_collection = "#{my_today} Collections"

      #puts "monthly_collection = #{monthly_collection}"
      #exit

      

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
         puts "***************"
         puts myp.inspect
         puts "**************"

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

        slugified_title = myp.original_state[:title].parameterize

        handle_ok = false
        if slugified_title == myp.original_state[:handle]
          handle_ok = true
        end
  
        puts "product_id: #{myp.original_state[:id]}, variant_id: #{myp.variants.first.original_state[:id]}, sku: #{myp.variants.first.original_state[:sku]}, product_title: #{myp.original_state[:title]}, price: #{myp.variants.first.original_state[:price]}, metafield: #{my_meta_str}, published_at: #{myp.original_state[:published_at]}, handle: #{myp.original_state[:handle]}, slugified_title: #{slugified_title}, handle_ok: #{handle_ok}"

        my_hash = {"product_title" => myp.original_state[:title], "product_id" => myp.original_state[:id], "variant_id" => myp.variants.first.original_state[:id], "sku" => myp.variants.first.original_state[:sku], "price" => myp.variants.first.original_state[:price], "product_collection" => my_meta_str, "published_at" => myp.original_state[:published_at], "handle" => myp.original_state[:handle], "slugified_title" => slugified_title, "handle_ok" => handle_ok}
        
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

          slugified_title = myp.original_state[:title].parameterize

          handle_ok = false
          if slugified_title == myp.original_state[:handle]
            handle_ok = true
          end
  
          puts "product_id: #{myp.original_state[:id]}, variant_id: #{myp.variants.first.original_state[:id]}, sku: #{myp.variants.first.original_state[:sku]}, product_title: #{myp.original_state[:title]}, price: #{myp.variants.first.original_state[:price]}, metafield: #{my_meta_str}, published_at: #{myp.original_state[:published_at]}, handle: #{myp.original_state[:handle]}, slugified_title: #{slugified_title}, handle_ok: #{handle_ok}"

          my_hash = {"product_title" => myp.original_state[:title], "product_id" => myp.original_state[:id], "variant_id" => myp.variants.first.original_state[:id], "sku" => myp.variants.first.original_state[:sku], "price" => myp.variants.first.original_state[:price], "product_collection" => my_meta_str, "published_at" => myp.original_state[:published_at], "handle" => myp.original_state[:handle], "slugified_title" => slugified_title, "handle_ok" => handle_ok}
        
          product_array.push(my_hash)
          
          
  
        end
      end
    end

    detail_product_collection = Array.new

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
        myp['product_match'] = true
      else
        puts "ERROR, product_count does not match the collection: products in collection = #{product_title_number}, prods in collection = #{product_count}"
        myp['product_match'] = false
      end

      next if  myp['product_collection'] =~ /ellie\spick/i
      my_products = ShopifyAPI::Product.all( collection_id: collection_id,  limit: 250 )

      my_products.each do |myprod|
        puts "-------------"
        puts myprod.inspect
        puts "-------------"
        temp_hash2 = {"product_collection" => myp['product_collection'], "product_name" => myprod.original_state[:title], "product_type" => myprod.original_state[:product_type], "options" => myprod.original_state[:options].first['name']}
        detail_product_collection.push(temp_hash2)

      end
      

    end

    detail_product_collection.each do |dpc|
      puts "*************"
      puts dpc.inspect
      puts "************"
    end
    puts "email = #{myemail}"

    File.delete('ellie_checklist_rollover.csv') if File.exist?('ellie_checklist_rollover.csv')

    

    column_header = ["product_title", "product_id", "variant_id", "sku", "price", "product_collection", "published_at", "product_count_match", "handle", "slugified_title", "handle_ok"]
        CSV.open('ellie_checklist_rollover.csv','a+', :write_headers=> true, :headers => column_header) do |hdr|
            column_header = nil
            product_array.each do |pa|
              csv_data_out = [pa['product_title'], pa["product_id"], pa['variant_id'], pa['sku'], pa['price'], pa['product_collection'], pa['published_at'], pa['product_match'], pa["handle"], pa["slugified_title"], pa["handle_ok"] ]
              hdr << csv_data_out

            end
            hdr << ["---------- Detail Product Collection info ------------"]
            hdr << ["product_collection", "product_name", "product_type", "options"]
            detail_product_collection.each do |dpc|
              if dpc["product_type"] =~ /bottom/i
                csv_data_out = [dpc['product_collection'], dpc["product_name"], dpc["product_type"], dpc['options'], "< ----- BADDDD Bottoms will break this collection"]
              else
                csv_data_out = [dpc['product_collection'], dpc["product_name"], dpc["product_type"], dpc['options']]
              end
              
              hdr << csv_data_out
            end

        end

    




    mystring = Base64.strict_encode64(File.open('ellie_checklist_rollover.csv', "rb").read)

    mail = SendGrid::Mail.new
    mail.from = Email.new(email: 'test@example.com')
    mail.subject = 'Ellie.com Rollover Checklist Report'
    personalization = Personalization.new
    personalization.add_to(Email.new(email: myemail, name: 'Floyd Wallace'))
    personalization.add_to(Email.new(email: 'flwallace99@gmail.com', name: 'Floyd Wallace'))
    personalization.subject = 'Here is the Ellie.com Rollover Checklist'
    mail.add_personalization(personalization)
    mail.add_content(Content.new(type: 'text/plain', value: 'See Attached CSV for Rollover Checklist'))
    attachment = Attachment.new
    attachment.content =  mystring
    attachment.type = 'application/csv'
    #attachment2.content = 'TG9'
    attachment.filename = 'ellie_checklist_rollover.csv'
    attachment.disposition = 'attachment'
    attachment.content_id = 'Ellie Rollover Checklist Report'
    mail.add_attachment(attachment)

    mail.reply_to = Email.new(email: 'test@example.com')

    # puts JSON.pretty_generate(mail.to_json)
    puts mail.to_json

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    puts response.status_code
    puts response.body
    puts response.headers



    puts "All done"

    end

end
end