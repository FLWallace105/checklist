#checklist.rb
require 'dotenv'
require 'httparty'
#require 'shopify_api'
# require 'active_record'
# require 'sinatra/activerecord'
#require 'logger'
require 'sendgrid-ruby'
require 'sinatra'
#require_relative './lib/shopify_api'
require 'active_support/core_ext/string/inflections'



Dotenv.load
Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file }
# Dir[File.join(__dir__, 'models', '*.rb')].each { |file| require file }

module Checklist
  class ShopifyGetter
    include SendGrid
    #extend ShopifyApi

    ACCEPTABLE_PRODUCT_TYPES = ["Tops", "tops", "Accessories", "Equipment", "Leggings", "Sports Bra", "Jacket", "Wrap", "sports-jacket", "Gloves", "Dress"]

    def initialize
      @shopname = ENV['SHOPIFY_SHOP_NAME']
      @api_key = ENV['SHOPIFY_API_KEY']
      @password = ENV['SHOPIFY_API_PASSWORD']
      @secret = ENV['SHOPIFY_SHARED_SECRET']
      @app_token = ENV['APP_TOKEN']

      
    end

    def shopify_get_all_resources(myemail)
   
      puts "Starting all shopify resources download"
    

    product_array = Array.new

    puts "#{@api_key}, #{@secret}, #{@shopname}, #{@app_token}"


    

      query = <<~PRODCNTQUERY
      {
        "query": "query { productsCount { count } }"
      }
      PRODCNTQUERY


      puts query
      puts @shopname
 
      new_header = ApiShopify.new(@shopname).get_change_header
      puts "new_header = #{new_header}"
      store_url = ApiShopify.new(@shopname).store_url
      new_prod_count_url = store_url + "graphql.json"
      puts new_prod_count_url
      puts "query here = #{JSON.generate(query)}"
    
    
      prod_count = HTTParty.post(new_prod_count_url, :headers => new_header, :body => query)
      puts "-------------- product count data ---------"
      puts prod_count.inspect

      my_product_count = prod_count.parsed_response['data']['productsCount']['count']
      puts "WE have #{my_product_count} products in #{@shopname}"

      
      my_start_month_plus = Date.today
      #before production add one month

      
      my_today = my_start_month_plus.strftime("%B %Y")
      monthly_collection = "#{my_today} Collections"
      slugified_monthly_collection = monthly_collection.parameterize
      puts "slugified_monthly_collection = #{slugified_monthly_collection}"

      

      my_collections = HTTParty.post(new_prod_count_url, :headers => new_header, 
          :body =>{
            query: <<-GRAPHQL
              {
                collectionByHandle(handle: "#{slugified_monthly_collection}") {
                  id
                  title
                  products(first: 25, reverse: true) {
                    edges {
                      node {
                        id
                        title
                        handle
                        productType
                        publishedAt
                        status
                        tags
                        createdAt
                        templateSuffix
                        ellie_order_info: metafield(namespace: "ellie_order_info", key: "product_collection") {
                              value
                            } 
                      variants(first: 25){
                        edges{
                          node {
                            id
                            barcode
                            sku
                            inventoryQuantity
                            price
                          
                          
                          }
                        }
                      }
                      }
                    }
                  }
                }
              }
            GRAPHQL
          }.to_json)

      


      puts "-------------- collection data ---------"
      #puts response.inspect
      puts my_collections.inspect

      my_data = my_collections.parsed_response['data']['collectionByHandle']['products']['edges']
      puts my_data


      my_data.each do |myd|
        temp_data = myd['node']
        temp_id = temp_data['id']
        fixed_id = temp_id.match(/(\d+)/).captures
        variant_id = temp_data['variants']['edges'].first['node']['id'].match(/(\d+)/).captures
        sku = temp_data['variants']['edges'].first['node']['sku']
        price = temp_data['variants']['edges'].first['node']['price']

        product_collection = nil
        if temp_data['ellie_order_info'] != {}
          product_collection = temp_data['ellie_order_info']['value']

        end

        title_equals_collection = false
        if  temp_data['title'] == product_collection
          title_equals_collection = true
        else
          title_equals_collection = false
        end

        slugified_title = temp_data['title'].parameterize

        handle_ok = false
        if slugified_title == temp_data['handle']
          handle_ok = true
        end

        my_hash = {"product_title" => temp_data['title'], "product_id" => fixed_id[0], "variant_id" => variant_id[0], "sku" => sku, "price" => price, "product_collection" => product_collection, "title_equals_collection" => title_equals_collection, "published_at" => temp_data['publishedAt'], "handle" => temp_data['handle'], "slugified_title" => slugified_title, "handle_ok" => handle_ok, "template_suffix" => temp_data['templateSuffix'], "status" => temp_data['status'], "tags" => temp_data['tags']}
          
        product_array.push(my_hash)

      end


      puts "product_array = #{product_array.inspect}"

      

     

      detail_product_collection = Array.new

      product_array.each do |pa|
        my_product_collection = pa['handle']

        my_prods_in_collections = HTTParty.post(new_prod_count_url, :headers => new_header, 
          :body =>{
            query: <<-GRAPHQL
              {
                collectionByHandle(handle: "#{my_product_collection}") {
                  id
                  title
                  products(first: 25, reverse: true) {
                    edges {
                      node {
                        id
                        title
                        handle
                        productType
                        options {
                          name
                          values
                        }
                        publishedAt
                        status
                        tags
                        createdAt
                        templateSuffix
                        ellie_order_info: metafield(namespace: "ellie_order_info", key: "product_collection") {
                              value
                            } 
                        
                      variants(first: 25){
                        edges{
                          node {
                            id
                            barcode
                            sku
                            title
                            inventoryQuantity
                            price
                          
                          
                          }
                        }
                      }
                      }
                    }
                  }
                }
              }
            GRAPHQL
          }.to_json)


      puts "products in this collection are :"
      puts my_prods_in_collections.inspect
      puts "-------------------------------"

      my_prod_data = my_prods_in_collections.parsed_response['data']['collectionByHandle']['products']['edges']
      puts "my_prod_data = #{my_prod_data}"
      my_prod_data.each do |myp|
        puts "*****************"
        puts myp
        puts "****************"

        temp_hash2 = {"product_collection" => pa['product_collection'], "product_name" => myp['node']['title'], "product_type" => myp['node']['productType'], "options" => myp['node']['options'].first['name'], "template_suffix" =>  myp['node']['templateSuffix'], "product_status" => myp['node']['status']}
        detail_product_collection.push(temp_hash2)

      end

      end

     
      puts "Detail_product_collection = #{detail_product_collection}"

      my_accum = Array.new

      detail_product_collection.each do |dp|
        my_accum.push(dp['product_collection'])

      end

      puts "my_accum = #{my_accum}"

      my_tally = my_accum.tally

      puts my_tally

      product_array.each do |pa|
        puts "product_array = #{pa.inspect}"
        my_coll_count = my_tally["#{pa['product_collection']}"]
        puts "my_coll_count = #{my_coll_count}"
        if my_coll_count == 3
          pa['product_match'] = true
        else
          pa['product_match'] = true
        end

      end

      




      

    
    puts "email = #{myemail}"

    File.delete('ellie_checklist_rollover.csv') if File.exist?('ellie_checklist_rollover.csv')

    

    column_header = ["product_title", "product_id", "variant_id", "sku", "price", "product_collection", "title_equals_collection", "published_at", "product_count_match", "handle", "slugified_title", "handle_ok", "template_suffix", "product_status", "Tapcart Tags OK"]
        CSV.open('ellie_checklist_rollover.csv','a+', :write_headers=> true, :headers => column_header) do |hdr|
            column_header = nil
            product_array.each do |pa|
              coll_tags_ok = tapcart_tags_ok(pa['tags'], pa['product_collection'])
              csv_data_out = [pa['product_title'], pa["product_id"], pa['variant_id'], pa['sku'], pa['price'], pa['product_collection'], pa['title_equals_collection'], pa['published_at'], pa['product_match'], pa["handle"], pa["slugified_title"], pa["handle_ok"], pa["template_suffix"], pa['status'], coll_tags_ok ]
              hdr << csv_data_out

            end
            hdr << ["---------- Detail Product Collection info ------------"]
            hdr << ["product_collection", "product_name", "product_type", "template_suffix", "options", "Not Used", "Not Used", "product_status", "product_status_ok", "product_type_ok" ]
            detail_product_collection.each do |dpc|
              if dpc["product_type"] =~ /bottom/i
                csv_data_out = [dpc['product_collection'], dpc["product_name"], dpc["product_type"], dpc['template_suffix'], dpc['options'], "< ----- BADDDD Bottoms will break this collection"]
              
                
              else
                product_status_production = product_status_ok(dpc["product_status"])
                temp_ok = product_type_ok(dpc["product_type"])
                csv_data_out = [dpc['product_collection'], dpc["product_name"], dpc["product_type"], dpc['template_suffix'], dpc['options'], "" , "" , dpc["product_status"], product_status_production, temp_ok]
              end
              
              hdr << csv_data_out
            end

        end

    




    mystring = Base64.strict_encode64(File.open('ellie_checklist_rollover.csv', "rb").read)

    mail = SendGrid::Mail.new
    mail.from = Email.new(email: 'checklist_info@zobha.com')
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

    mail.reply_to = Email.new(email: 'checklist_info@zobha.com')

    # puts JSON.pretty_generate(mail.to_json)
    puts mail.to_json

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._('send').post(request_body: mail.to_json)
    puts response.status_code
    puts response.body
    puts response.headers



    puts "All done"

    end

    def product_status_ok(product_status)
      if product_status.downcase == "active"
        return true
      else
        return false
      end
    end


    def product_type_ok(product_type)
      my_ok = ACCEPTABLE_PRODUCT_TYPES.include?(product_type)
      return my_ok

    end

    def  tapcart_tags_ok(my_tags, product_collection)
      tags_ok = false
      if my_tags.include? product_collection
        tags_ok = true
      end
      return tags_ok
    end

end
end